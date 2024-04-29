--------------------------------------------------------
--  DDL for Package JTF_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfptkts.pls 120.17.12010000.3 2009/09/07 13:07:50 anangupt ship $ */
  /*#
   * A public interface for Tasks that can be used to create, update and delete tasks.
   * Tasks can be standalone tasks or tasks associated with a specific business entity
   * such as Opportunity, Service Request, Customer, etc. Do not use these APIs
   * for managing Field Service tasks related to service requests.
   *
   * @rep:scope public
   * @rep:product CAC
   * @rep:lifecycle active
   * @rep:displayname Task Management
   * @rep:compatibility S
   * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
   */
  g_pkg_name      CONSTANT VARCHAR2(30)      := 'JTF_TASKS_PUB';
  g_user          CONSTANT VARCHAR2(30)      := fnd_global.user_id;
  g_false         CONSTANT VARCHAR2(30)      := fnd_api.g_false;
  g_true          CONSTANT VARCHAR2(30)      := fnd_api.g_true;

  TYPE task_details_rec IS RECORD(
    task_id          NUMBER
  , task_template_id NUMBER
  );

  TYPE task_assign_rec IS RECORD(
    resource_type_code         jtf_task_assignments.resource_type_code%TYPE
  , resource_id                jtf_task_assignments.resource_id%TYPE
  , actual_start_date          DATE                                                   := NULL
  , actual_end_date            DATE                                                   := NULL
  , actual_effort              jtf_task_assignments.actual_effort%TYPE                := NULL
  , actual_effort_uom          jtf_task_assignments.actual_effort_uom%TYPE            := NULL
  , sched_travel_distance      jtf_task_assignments.sched_travel_distance%TYPE        := NULL
  , sched_travel_duration      jtf_task_assignments.sched_travel_duration%TYPE        := NULL
  , sched_travel_duration_uom  jtf_task_assignments.sched_travel_duration_uom%TYPE    := NULL
  , actual_travel_distance     jtf_task_assignments.actual_travel_distance%TYPE       := NULL
  , actual_travel_duration     jtf_task_assignments.actual_travel_duration%TYPE       := NULL
  , actual_travel_duration_uom jtf_task_assignments.actual_travel_duration_uom%TYPE   := NULL
  , schedule_flag              jtf_task_assignments.schedule_flag%TYPE                := NULL
  , alarm_type_code            jtf_task_assignments.alarm_type_code%TYPE              := NULL
  , alarm_contact              jtf_task_assignments.alarm_contact%TYPE                := NULL
  , palm_flag                  jtf_task_assignments.palm_flag%TYPE                    := NULL
  , wince_flag                 jtf_task_assignments.wince_flag%TYPE                   := NULL
  , laptop_flag                jtf_task_assignments.laptop_flag%TYPE                  := NULL
  , device1_flag               jtf_task_assignments.device1_flag%TYPE                 := NULL
  , device2_flag               jtf_task_assignments.device2_flag%TYPE                 := NULL
  , device3_flag               jtf_task_assignments.device3_flag%TYPE                 := NULL
  , resource_territory_id      jtf_task_assignments.resource_territory_id%TYPE        := NULL
  , assignment_status_id       jtf_task_assignments.assignment_status_id%TYPE         := NULL
  , shift_construct_id         jtf_task_assignments.shift_construct_id%TYPE           := NULL
  , show_on_calendar           jtf_task_assignments.show_on_calendar%TYPE             := NULL
  , category_id                jtf_task_assignments.category_id%TYPE                  := NULL
  );

  TYPE task_assign_tbl IS TABLE OF task_assign_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_assign_tbl   task_assign_tbl;

  TYPE task_depends_rec IS RECORD(
    dependent_on_task_id     NUMBER       := NULL
  , dependent_on_task_number NUMBER       := NULL
  , dependency_type_code     VARCHAR2(30)
  , adjustment_time          NUMBER       := NULL
  , adjustment_time_uom      VARCHAR2(3)  := NULL
  , validated_flag           VARCHAR2(1)  := NULL
  );

  TYPE task_depends_tbl IS TABLE OF task_depends_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_depends_tbl  task_depends_tbl;

  TYPE task_rsrc_req_rec IS RECORD(
    resource_type_code jtf_task_rsc_reqs.resource_type_code%TYPE
  , required_units     jtf_task_rsc_reqs.required_units%TYPE
  , enabled_flag       jtf_task_rsc_reqs.enabled_flag%TYPE         := jtf_task_utl.g_no
  );

  TYPE task_rsrc_req_tbl IS TABLE OF task_rsrc_req_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_rsrc_req_tbl task_rsrc_req_tbl;

  TYPE task_refer_rec IS RECORD(
    object_type_code jtf_objects_b.object_code%TYPE
  , object_type_name jtf_objects_tl.NAME%TYPE
  , object_name      VARCHAR2(80)
  , object_id        NUMBER
  , object_details   VARCHAR2(2000)
  , reference_code   VARCHAR2(30)
  , USAGE            VARCHAR2(2000)
  );

  TYPE task_refer_tbl IS TABLE OF task_refer_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_refer_tbl    task_refer_tbl;

  TYPE task_recur_rec IS RECORD(
    occurs_which      NUMBER      := NULL
  , day_of_week       NUMBER      := NULL
  , date_of_month     NUMBER      := NULL
  , occurs_month      NUMBER      := NULL
  , occurs_uom        VARCHAR2(3)
  , occurs_every      NUMBER      := NULL
  , occurs_number     NUMBER      := NULL
  , start_date_active DATE        := NULL
  , end_date_active   DATE        := NULL
  );

  g_miss_task_recur_rec    task_recur_rec;

  TYPE task_dates_rec IS RECORD(
    date_type_id   NUMBER       DEFAULT NULL
  , date_type_name VARCHAR2(30) DEFAULT NULL
  , date_type      VARCHAR2(30) DEFAULT NULL
  , date_value     DATE
  );

  TYPE task_dates_tbl IS TABLE OF task_dates_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_dates_tbl    task_dates_tbl;

  TYPE task_notes_rec IS RECORD(
    parent_note_id NUMBER
  , org_id         NUMBER
  , notes          VARCHAR2(4000)
  , notes_detail   VARCHAR2(32767)
  , note_status    VARCHAR2(1)
  , entered_by     NUMBER
  , entered_date   DATE
  , note_type      VARCHAR2(30)
  , jtf_note_id    NUMBER
  , attribute1     VARCHAR2(150)
  , attribute2     VARCHAR2(150)
  , attribute3     VARCHAR2(150)
  , attribute4     VARCHAR2(150)
  , attribute5     VARCHAR2(150)
  , attribute6     VARCHAR2(150)
  , attribute7     VARCHAR2(150)
  , attribute8     VARCHAR2(150)
  , attribute9     VARCHAR2(150)
  , attribute10    VARCHAR2(150)
  , attribute11    VARCHAR2(150)
  , attribute12    VARCHAR2(150)
  , attribute13    VARCHAR2(150)
  , attribute14    VARCHAR2(150)
  , attribute15    VARCHAR2(150)
  , CONTEXT        VARCHAR2(30)
  );

  TYPE task_notes_tbl IS TABLE OF task_notes_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_notes_tbl    task_notes_tbl;

  TYPE task_contacts_rec IS RECORD(
    contact_id                NUMBER       DEFAULT NULL
  , contact_type_code         VARCHAR2(30) DEFAULT NULL
  , escalation_notify_flag    VARCHAR2(1)  DEFAULT NULL
  , escalation_requester_flag VARCHAR2(1)  DEFAULT NULL
  );

  TYPE task_contacts_tbl IS TABLE OF task_contacts_rec
    INDEX BY BINARY_INTEGER;

  g_miss_task_contacts_tbl task_contacts_tbl;

  TYPE task_user_hooks IS RECORD(
    task_id                   NUMBER
  , task_name                 VARCHAR2(80)
  , task_type_name            VARCHAR2(80)
  , task_type_id              NUMBER
  , description               VARCHAR2(4000)
  , task_status_name          VARCHAR2(80)
  , task_status_id            NUMBER
  , task_priority_name        VARCHAR2(80)
  , task_priority_id          NUMBER
  , owner_type_name           VARCHAR2(80)
  , owner_type_code           VARCHAR2(80)
  , owner_id                  NUMBER
  , owner_territory_id        NUMBER
  , assigned_by_name          VARCHAR2(80)
  , assigned_by_id            NUMBER
  , customer_number           VARCHAR2(30)
  , customer_id               NUMBER
  , cust_account_number       VARCHAR2(30)
  , cust_account_id           NUMBER
  , address_id                NUMBER
  , address_number            VARCHAR2(30)
  , planned_start_date        DATE
  , planned_end_date          DATE
  , scheduled_start_date      DATE
  , scheduled_end_date        DATE
  , actual_start_date         DATE
  , actual_end_date           DATE
  , timezone_id               NUMBER
  , timezone_name             VARCHAR2(50)
  , source_object_type_code   VARCHAR2(30)
  , source_object_id          NUMBER
  , source_object_name        VARCHAR2(80)
  , duration                  NUMBER
  , duration_uom              VARCHAR2(3)
  , planned_effort            NUMBER
  , planned_effort_uom        VARCHAR2(3)
  , actual_effort             NUMBER
  , actual_effort_uom         VARCHAR2(3)
  , percentage_complete       NUMBER
  , reason_code               VARCHAR2(30)
  , private_flag              VARCHAR2(1)
  , publish_flag              VARCHAR2(1)
  , restrict_closure_flag     VARCHAR2(1)
  , multi_booked_flag         VARCHAR2(1)
  , milestone_flag            VARCHAR2(1)
  , holiday_flag              VARCHAR2(1)
  , billable_flag             VARCHAR2(1)
  , bound_mode_code           VARCHAR2(30)
  , soft_bound_flag           VARCHAR2(1)
  , workflow_process_id       NUMBER
  , notification_flag         VARCHAR2(1)
  , notification_period       NUMBER
  , notification_period_uom   VARCHAR2(3)
  , parent_task_number        VARCHAR2(30)
  , parent_task_id            NUMBER
  , alarm_start               NUMBER
  , alarm_start_uom           VARCHAR2(3)
  , alarm_on                  VARCHAR2(1)
  , alarm_count               NUMBER
  , alarm_interval            NUMBER
  , alarm_interval_uom        VARCHAR2(3)
  , palm_flag                 VARCHAR2(1)
  , wince_flag                VARCHAR2(1)
  , laptop_flag               VARCHAR2(1)
  , device1_flag              VARCHAR2(1)
  , device2_flag              VARCHAR2(1)
  , device3_flag              VARCHAR2(1)
  , costs                     NUMBER
  , currency_code             VARCHAR2(3)
  , escalation_level          VARCHAR2(30)
  , date_selected             VARCHAR2(1)
  , template_id               NUMBER
  , template_group_id         NUMBER
  , task_number               VARCHAR2(30)
  , attribute1                VARCHAR2(150)
  , attribute2                VARCHAR2(150)
  , attribute3                VARCHAR2(150)
  , attribute4                VARCHAR2(150)
  , attribute5                VARCHAR2(150)
  , attribute6                VARCHAR2(150)
  , attribute7                VARCHAR2(150)
  , attribute8                VARCHAR2(150)
  , attribute9                VARCHAR2(150)
  , attribute10               VARCHAR2(150)
  , attribute11               VARCHAR2(150)
  , attribute12               VARCHAR2(150)
  , attribute13               VARCHAR2(150)
  , attribute14               VARCHAR2(150)
  , attribute15               VARCHAR2(150)
  , attribute_category        VARCHAR2(150)
  , entity                    VARCHAR2(30)
  , task_split_flag           VARCHAR2(1)
  , child_position            VARCHAR2(1)
  , child_sequence_num        NUMBER
  , task_confirmation_status  VARCHAR2(1)
  , task_confirmation_counter NUMBER
  , open_flag                 VARCHAR2(1)
  , location_id               NUMBER
  , copied_from_task_id       NUMBER
  );

  p_task_user_hooks        task_user_hooks;

  TYPE task_rec IS RECORD(
    task_id                 jtf_tasks_v.task_id%TYPE
  , task_number             jtf_tasks_v.task_number%TYPE
  , task_name               jtf_tasks_v.task_name%TYPE
  , description             jtf_tasks_v.description%TYPE
  , task_type_id            jtf_tasks_v.task_type_id%TYPE
  , task_type               jtf_tasks_v.task_type%TYPE
  , task_status_id          jtf_tasks_v.task_status_id%TYPE
  , task_status             jtf_tasks_v.task_status%TYPE
  , task_priority_id        jtf_tasks_v.task_priority_id%TYPE
  , task_priority           jtf_tasks_v.task_priority%TYPE
  , owner_type_code         jtf_tasks_v.owner_type_code%TYPE
  , owner_id                jtf_tasks_v.owner_id%TYPE
  , owner                   jtf_tasks_v.owner%TYPE
  , assigned_by_id          jtf_tasks_v.assigned_by_id%TYPE
  , assigned_by_name        jtf_tasks_v.assigned_by_name%TYPE
  , customer_id             jtf_tasks_v.customer_id%TYPE
  , customer_name           jtf_tasks_v.customer_name%TYPE
  , customer_number         jtf_tasks_v.customer_number%TYPE
  , cust_account_number     jtf_tasks_v.cust_account_number%TYPE
  , cust_account_id         jtf_tasks_v.cust_account_id%TYPE
  , address_id              jtf_tasks_v.address_id%TYPE
  , planned_start_date      jtf_tasks_v.planned_start_date%TYPE
  , planned_end_date        jtf_tasks_v.planned_end_date%TYPE
  , scheduled_start_date    jtf_tasks_v.scheduled_start_date%TYPE
  , scheduled_end_date      jtf_tasks_v.scheduled_end_date%TYPE
  , actual_start_date       jtf_tasks_v.actual_start_date%TYPE
  , actual_end_date         jtf_tasks_v.actual_end_date%TYPE
  , object_type_code        jtf_tasks_v.source_object_type_code%TYPE
  , object_id               jtf_tasks_v.source_object_id%TYPE
  , obect_name              jtf_tasks_v.source_object_name%TYPE
  , DURATION                jtf_tasks_v.DURATION%TYPE
  , duration_uom            jtf_tasks_v.duration_uom%TYPE
  , planned_effort          jtf_tasks_v.planned_effort%TYPE
  , planned_effort_uom      jtf_tasks_v.planned_effort_uom%TYPE
  , actual_effort           jtf_tasks_v.actual_effort%TYPE
  , actual_effort_uom       jtf_tasks_v.actual_effort_uom%TYPE
  , percentage_complete     jtf_tasks_v.percentage_complete%TYPE
  , reason_code             jtf_tasks_v.reason_code%TYPE
  , private_flag            jtf_tasks_v.private_flag%TYPE
  , publish_flag            jtf_tasks_v.publish_flag%TYPE
  , multi_booked_flag       jtf_tasks_v.multi_booked_flag%TYPE
  , milestone_flag          jtf_tasks_v.milestone_flag%TYPE
  , holiday_flag            jtf_tasks_v.holiday_flag%TYPE
  , workflow_process_id     jtf_tasks_v.workflow_process_id%TYPE
  , notification_flag       jtf_tasks_v.notification_flag%TYPE
  , notification_period     jtf_tasks_v.notification_period%TYPE
  , notification_period_uom jtf_tasks_v.notification_period_uom%TYPE
  , parent_task_id          jtf_tasks_v.parent_task_id%TYPE
  , alarm_start             jtf_tasks_v.alarm_start%TYPE
  , alarm_start_uom         jtf_tasks_v.alarm_start_uom%TYPE
  , alarm_on                jtf_tasks_v.alarm_on%TYPE
  , alarm_count             jtf_tasks_v.alarm_count%TYPE
  , alarm_fired_count       jtf_tasks_v.alarm_fired_count%TYPE
  , alarm_interval          jtf_tasks_v.alarm_interval%TYPE
  , alarm_interval_uom      jtf_tasks_v.alarm_interval_uom%TYPE
  , attribute1              jtf_tasks_v.attribute1%TYPE
  , attribute2              jtf_tasks_v.attribute2%TYPE
  , attribute3              jtf_tasks_v.attribute3%TYPE
  , attribute4              jtf_tasks_v.attribute4%TYPE
  , attribute5              jtf_tasks_v.attribute5%TYPE
  , attribute6              jtf_tasks_v.attribute6%TYPE
  , attribute7              jtf_tasks_v.attribute7%TYPE
  , attribute8              jtf_tasks_v.attribute8%TYPE
  , attribute9              jtf_tasks_v.attribute9%TYPE
  , attribute10             jtf_tasks_v.attribute10%TYPE
  , attribute11             jtf_tasks_v.attribute11%TYPE
  , attribute12             jtf_tasks_v.attribute12%TYPE
  , attribute13             jtf_tasks_v.attribute13%TYPE
  , attribute14             jtf_tasks_v.attribute14%TYPE
  , attribute15             jtf_tasks_v.attribute15%TYPE
  , attribute_category      jtf_tasks_v.attribute_category%TYPE
  , owner_territory_id      jtf_tasks_v.owner_territory_id%TYPE
  , creation_date           jtf_tasks_v.creation_date%TYPE
  , escalation_level        jtf_tasks_v.escalation_level%TYPE
  , object_version_number   jtf_tasks_v.object_version_number%TYPE
  , calendar_start_date     jtf_tasks_b.calendar_start_date%TYPE
  , calendar_end_date       jtf_tasks_b.calendar_end_date%TYPE
  , date_selected           jtf_tasks_b.date_selected%TYPE
  , task_split_flag         jtf_tasks_v.task_split_flag%TYPE
  , child_position          jtf_tasks_vl.child_position%TYPE
  , child_sequence_num      jtf_tasks_vl.child_sequence_num%TYPE
  , location_id             jtf_tasks_vl.location_id%TYPE
  );

  TYPE task_table_type IS TABLE OF task_rec
    INDEX BY BINARY_INTEGER;

  task_tbl                 task_table_type;

  TYPE sort_rec IS RECORD(
    field_name   VARCHAR2(30)
  , asc_dsc_flag CHAR(1)      DEFAULT 'A'
  );

  TYPE sort_data IS TABLE OF sort_rec
    INDEX BY BINARY_INTEGER;

  /*#
   * Creates a standalone task or a task associated with a specific business entity.
   *
   * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @rep:paraminfo {@rep:required}
   * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
   * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
   * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
   *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
   *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
   *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
   * @param x_msg_count Number of messages returned in the API message list.
   * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
   * @param x_task_id Unique task identifier of the task being created.
   * @param p_task_id Unique task identifier. It will be generated from the sequence <code>jtf_tasks_s</code> when not passed.
   * @param p_task_name Subject of the task.
   * @paraminfo {@rep:precision 80} {@rep:required}
   * @param p_task_type_name Task type name. Either type name or <code>p_task_type_id</code> must be passed.
   * @rep:paraminfo {@rep:required}
   * @param p_task_type_id Unique task type identifier. This is a foreign key to <code>jtf_task_types_b.task_type_id</code>.
   * @rep:paraminfo {@rep:required}
   * @param p_description Optional task description.
   * @paraminfo {@rep:precision 4000}
   * @param p_task_status_name Task status name. Either status name or <code>p_task_status_id</code> must be passed.
   * @rep:paraminfo {@rep:required}
   * @param p_task_status_id Unique task status identifier. This is a foreign key to <code>jtf_task_statuses_b.task_status_id</code>.
   * @rep:paraminfo {@rep:required}
   * @param p_task_priority_name Task priority name. Either priority name or <code>p_task_priority_id</code> can be passed.
   * @param p_task_priority_id Unique task priority identifier. This is a foreign key to <code>jtf_task_priorities_b.task_priority_id</code>.
   * @param p_owner_type_name No longer in use.
   * @param p_owner_type_code Resource type code for the task owner. A task owner is identified with the task resource type code and task resource identifier, therefore this should be used along with <code>p_owner_id</code>.
   * @rep:paraminfo {@rep:required}
   * @param p_owner_id Resource identifier for the task owner. Should be used along with <code>p_owner_type_code</code>.
   * @rep:paraminfo {@rep:required}
   * @param p_owner_territory_id Territory identification of the task owner.
   * @param p_assigned_by_name No longer in use.
   * @param p_assigned_by_id No longer in use.
   * @param p_customer_number Unique customer number. Either customer number or <code>p_customer_id</code> can be passed to associate the customer with the task.
   * This is validated against <code>hz_parties.party_number</code>.
   * @param p_customer_id Unique customer identifier. Either customer identifier or <code>p_customer_number</code> can be passed to associate the customer with the task.
   * This is validated against <code>hz_parties.party_id</code>.
   * @param p_cust_account_number Customer account number that can be set on a task with an associated customer. Either customer account number or <code>p_customer_account_id</code> can be passed.
   * This is validated against <code>hz_cust_accounts.account_number</code>.
   * @param p_cust_account_id Unique customer account identifier that can be set on a task with an associated customer. Either customer account identifier or <code>p_customer_account_number</code> can be passed.
   * This is validated against <code>hz_cust_accounts.cust_account_id</code>.
   * @param p_address_number Customer address number that can be set on a task with an associated customer. Either customer address number or <code>p_address_id</code> can be passed.
   * This is validated against <code>hz_party_sites.party_site_number</code>.
   * @param p_address_id Unique customer address identifier that can be set on a task with an associated customer. Either customer address identifier or <code>p_address_number</code> can be passed.
   * This is validated against <code>hz_party_sites.party_site_id</code>.
   * @param p_planned_start_date Planned start date for this task.
   * @param p_planned_end_date Planned end date for this task.
   * @param p_scheduled_start_date Scheduled start date for this task.
   * @param p_scheduled_end_date Scheduled end date for this task.
   * @param p_actual_start_date Actual start date for this task.
   * @param p_actual_end_date Actual end date for this task.
   * @param p_timezone_id Timezone identifier used for this task dates. Either timezone identifier or <code>p_timezone_name</code> can be passed. This is validated against <code>hz_timezones.timezone_id</code>.
   * @param p_timezone_name Timezone name used for this task dates. Either timezone name or <code>p_timezone_id</code> can be passed. This is validated against <code>hz_timezones.global_timezone_name</code>.
   * @param p_source_object_type_code Object code used as the source type for this task. The object code can be either <code>'TASK'</code> for standalone tasks or a registered object with usage of <code>'TASK'</code> for contextual tasks.
   * This is a foreign key to <code>jtf_objects_b.object_code</code>.
   * @param p_source_object_id Unique source object identifier used to identify and validate the task source. This must be provided for any contextual task.
   * @param p_source_object_name No longer in use.
   * @param p_duration Duration of this task. Should be used along with <code>p_duration_uom</code>.
   * @param p_duration_uom Unit of measure for the duration. Should be used along with <code>p_duration</code>.
   * @param p_planned_effort Planned effort for this task. Should be used along with <code>p_planned_effort_uom</code>.
   * @param p_planned_effort_uom Unit of Measure for the planned effort. Should be used along with <code>p_planned_effort</code>.
   * @param p_actual_effort Actual effort exerted for this task. Should be used along with <code>p_actual_effort_uom</code>.
   * @param p_actual_effort_uom Unit of Measure for the actual effort. Should be used along with <code>p_actual_effort</code>.
   * @param p_percentage_complete Percentage of this task completion.
   * @param p_reason_code Reserved for internal use only. Reason code is used to check if the task is automated.
   * @param p_private_flag Flag used to mark this task as a private task. This flag is used by task user interface to limit the task visibility to the task owner and assignee only.
   * @param p_publish_flag Flag used to mark this task as a published task. This flag is used by task user interface to set the task for publishing.
   * @param p_restrict_closure_flag Reserved for internal use only.
   * @param p_multi_booked_flag Reserved for internal use only.
   * @param p_milestone_flag Flag used to mark this task as milestone.
   * @param p_holiday_flag Flag used to mark this task execution during holidays.
   * @param p_billable_flag Flag used to mark this task for billing.
   * @param p_bound_mode_code Reserved for internal use only.
   * @param p_soft_bound_flag Reserved for internal use only.
   * @param p_workflow_process_id Process identifier of last workflow launched.
   * @param p_notification_flag Notification flag used to automatically launch workflow.
   * @param p_notification_period Notification period is the time period after which workflow is sent to the task assignees. Should be used along with <code>p_notification_period_uom</code>.
   * @param p_notification_period_uom Unit of measure for notification period. Should be used along with <code>p_notification_period</code>.
   * @param p_parent_task_number Parent task number for this tasks.  Either parent task number or <code>p_parent_task_number</code> can be passed.
   * @param p_parent_task_id Parent task identifier for this tasks.  Either parent task identifier or <code>p_parent_task_id</code> can be passed.
   * @param p_alarm_start Time when the first alarm is fired. Should be used along with <code>p_alarm_start_uom</code>.
   * @param p_alarm_start_uom Unit of measure for alarm start. Should be used along with <code>p_alarm_start</code>.
   * @param p_alarm_on Indicates that alarm is turned on.
   * @param p_alarm_count Total number of alarms.
   * @param p_alarm_interval Alarm firing interval. Should be used along with <code>p_alarm_interval_uom</code>.
   * @param p_alarm_interval_uom Unit of measure for alarm interval. Should be used along with <code>p_alarm_interval</code>.
   * @param p_palm_flag Reserved for internal use only.
   * @param p_wince_flag Reserved for internal use only.
   * @param p_laptop_flag Reserved for internal use only.
   * @param p_device1_flag Reserved for internal use only.
   * @param p_device2_flag Reserved for internal use only.
   * @param p_device3_flag Reserved for internal use only.
   * @param p_costs Reserved for internal use only.
   * @param p_currency_code Reserved for internal use only.
   * @param p_escalation_level Level of escalation used by Escalation Module.
   * @param p_task_assign_tbl Table of task assignment records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_depends_tbl Table of dependent task records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_rsrc_req_tbl Table of task resource requirement records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_refer_tbl Table of task reference records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_dates_tbl Table of task dates records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_notes_tbl Table of task notes records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_recur_rec Task recurrence record. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_task_contacts_tbl Table of task customer contact records. For details see: Oracle Common Application Calendar - API Reference Guide.
   * @param p_attribute1 Attribute1 of customer flex fields.
   * @param p_attribute2 Attribute2 of customer flex fields.
   * @param p_attribute3 Attribute3 of customer flex fields.
   * @param p_attribute4 Attribute4 of customer flex fields.
   * @param p_attribute5 Attribute5 of customer flex fields.
   * @param p_attribute6 Attribute6 of customer flex fields.
   * @param p_attribute7 Attribute7 of customer flex fields.
   * @param p_attribute8 Attribute8 of customer flex fields.
   * @param p_attribute9 Attribute9 of customer flex fields.
   * @param p_attribute10 Attribute10 of customer flex fields.
   * @param p_attribute11 Attribute11 of customer flex fields.
   * @param p_attribute12 Attribute12 of customer flex fields.
   * @param p_attribute13 Attribute13 of customer flex fields.
   * @param p_attribute14 Attribute14 of customer flex fields.
   * @param p_attribute15 Attribute15 of customer flex fields.
   * @param p_attribute_category Attribute category for the customer flex fields.
   * @param p_date_selected Flag used to select which date pair (Planned, Scheduled, or Actual) will be used as calendar date. The default value is set by profile option, if not passed.
   * @param p_category_id Reserved unique identifier for personal category defined by resource in their calendar. This is a foreign key to <code>jtf_perz_data.perz_date_id</code>.
   * @param p_show_on_calendar Flag to show task on resource's calendar. The task will only show up on Resource's calendar if this flag is set to <code>'Y'</code> and there is a set of date with time present on task level.
   * This flag is defaulted to <code>'Y'</code> if not passed.
   * @param p_owner_status_id No longer in use.
   * @param p_template_id Unique template identifier of task template used for creating this task.
   * @param p_template_group_id Unique template group identifier of template group that contains the task template used for creating this task.
   * @param p_enable_workflow Flag to enable workflow passed as-is to <code>oracle.apps.jtf.cac.task.createTask</code> business event.
   * @param p_abort_workflow Flag to abort workflow passed as-is to <code>oracle.apps.jtf.cac.task.createTask</code> business event.
   * @param p_task_split_flag Reserved for internal use only. This flag is used to denote split tasks created by Field Service.
   * The following two values are currently used:
   * <LI><code>'M'</code> - for a master (parent) task
   * <LI><code>'D'</code> - for a dependent (child) task.
   * @param p_reference_flag Reserved for internal use only. It is used to note API about references that are already created.
   * @param p_child_position Reserved for internal use only. This flag is used by Field Service to mark child position for split tasks
   * @param p_child_sequence_num Reserved for internal use only. It is used by Field Service to mark child sequence for split tasks
   * @param p_location_id Reserved for internal use only. It is used by Field Service to store location id in task table
   * @rep:paraminfo {@rep:required}
   *
   * @rep:primaryinstance
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Create Task
   * @rep:compatibility S
   * @rep:businessevent oracle.apps.jtf.cac.task.createTask
   * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
   * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
   * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
   * @rep:category BUSINESS_ENTITY AMS_LEAD
   */
  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_name          IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_name        IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_name      IN            VARCHAR2 DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_name         IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_number         IN            VARCHAR2 DEFAULT NULL
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT NULL
  , p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
  , p_timezone_name           IN            VARCHAR2 DEFAULT NULL
  , p_source_object_type_code IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id        IN            NUMBER DEFAULT NULL
  , p_source_object_name      IN            VARCHAR2 DEFAULT NULL
  , p_duration                IN            NUMBER DEFAULT NULL
  , p_duration_uom            IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort          IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort           IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete     IN            NUMBER DEFAULT NULL
  , p_reason_code             IN            VARCHAR2 DEFAULT NULL
  , p_private_flag            IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag            IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag          IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag            IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag           IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id     IN            NUMBER DEFAULT NULL
  , p_notification_flag       IN            VARCHAR2 DEFAULT NULL
  , p_notification_period     IN            NUMBER DEFAULT NULL
  , p_notification_period_uom IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_number      IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id          IN            NUMBER DEFAULT NULL
  , p_alarm_start             IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count             IN            NUMBER DEFAULT NULL
  , p_alarm_interval          IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag               IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag              IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag            IN            VARCHAR2 DEFAULT NULL
  , p_costs                   IN            NUMBER DEFAULT NULL
  , p_currency_code           IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level        IN            VARCHAR2 DEFAULT NULL
  , p_task_assign_tbl         IN            task_assign_tbl DEFAULT g_miss_task_assign_tbl
  , p_task_depends_tbl        IN            task_depends_tbl DEFAULT g_miss_task_depends_tbl
  , p_task_rsrc_req_tbl       IN            task_rsrc_req_tbl DEFAULT g_miss_task_rsrc_req_tbl
  , p_task_refer_tbl          IN            task_refer_tbl DEFAULT g_miss_task_refer_tbl
  , p_task_dates_tbl          IN            task_dates_tbl DEFAULT g_miss_task_dates_tbl
  , p_task_notes_tbl          IN            task_notes_tbl DEFAULT g_miss_task_notes_tbl
  , p_task_recur_rec          IN            task_recur_rec DEFAULT g_miss_task_recur_rec
  , p_task_contacts_tbl       IN            task_contacts_tbl DEFAULT g_miss_task_contacts_tbl
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , x_task_id                 OUT NOCOPY    NUMBER
  , p_attribute1              IN            VARCHAR2 DEFAULT NULL
  , p_attribute2              IN            VARCHAR2 DEFAULT NULL
  , p_attribute3              IN            VARCHAR2 DEFAULT NULL
  , p_attribute4              IN            VARCHAR2 DEFAULT NULL
  , p_attribute5              IN            VARCHAR2 DEFAULT NULL
  , p_attribute6              IN            VARCHAR2 DEFAULT NULL
  , p_attribute7              IN            VARCHAR2 DEFAULT NULL
  , p_attribute8              IN            VARCHAR2 DEFAULT NULL
  , p_attribute9              IN            VARCHAR2 DEFAULT NULL
  , p_attribute10             IN            VARCHAR2 DEFAULT NULL
  , p_attribute11             IN            VARCHAR2 DEFAULT NULL
  , p_attribute12             IN            VARCHAR2 DEFAULT NULL
  , p_attribute13             IN            VARCHAR2 DEFAULT NULL
  , p_attribute14             IN            VARCHAR2 DEFAULT NULL
  , p_attribute15             IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category      IN            VARCHAR2 DEFAULT NULL
  , p_date_selected           IN            VARCHAR2 DEFAULT NULL
  , p_category_id             IN            NUMBER DEFAULT NULL
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id         IN            NUMBER DEFAULT NULL
  , p_template_id             IN            NUMBER DEFAULT NULL
  , p_template_group_id       IN            NUMBER DEFAULT NULL
  , p_enable_workflow         IN            VARCHAR2
        DEFAULT fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
  , p_abort_workflow          IN            VARCHAR2
        DEFAULT fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
  , p_task_split_flag         IN            VARCHAR2 DEFAULT NULL
  , p_reference_flag          IN            VARCHAR2 DEFAULT NULL
  , p_child_position          IN            VARCHAR2 DEFAULT NULL
  , p_child_sequence_num      IN            NUMBER DEFAULT NULL
  , p_location_id             IN            NUMBER
  );

  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_name          IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_name        IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_name      IN            VARCHAR2 DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_name         IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_number         IN            VARCHAR2 DEFAULT NULL
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT NULL
  , p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
  , p_timezone_name           IN            VARCHAR2 DEFAULT NULL
  , p_source_object_type_code IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id        IN            NUMBER DEFAULT NULL
  , p_source_object_name      IN            VARCHAR2 DEFAULT NULL
  , p_duration                IN            NUMBER DEFAULT NULL
  , p_duration_uom            IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort          IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort           IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete     IN            NUMBER DEFAULT NULL
  , p_reason_code             IN            VARCHAR2 DEFAULT NULL
  , p_private_flag            IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag            IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag          IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag            IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag           IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id     IN            NUMBER DEFAULT NULL
  , p_notification_flag       IN            VARCHAR2 DEFAULT NULL
  , p_notification_period     IN            NUMBER DEFAULT NULL
  , p_notification_period_uom IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_number      IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id          IN            NUMBER DEFAULT NULL
  , p_alarm_start             IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count             IN            NUMBER DEFAULT NULL
  , p_alarm_interval          IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag               IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag              IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag            IN            VARCHAR2 DEFAULT NULL
  , p_costs                   IN            NUMBER DEFAULT NULL
  , p_currency_code           IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level        IN            VARCHAR2 DEFAULT NULL
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , x_task_id                 OUT NOCOPY    NUMBER
  , p_attribute1              IN            VARCHAR2 DEFAULT NULL
  , p_attribute2              IN            VARCHAR2 DEFAULT NULL
  , p_attribute3              IN            VARCHAR2 DEFAULT NULL
  , p_attribute4              IN            VARCHAR2 DEFAULT NULL
  , p_attribute5              IN            VARCHAR2 DEFAULT NULL
  , p_attribute6              IN            VARCHAR2 DEFAULT NULL
  , p_attribute7              IN            VARCHAR2 DEFAULT NULL
  , p_attribute8              IN            VARCHAR2 DEFAULT NULL
  , p_attribute9              IN            VARCHAR2 DEFAULT NULL
  , p_attribute10             IN            VARCHAR2 DEFAULT NULL
  , p_attribute11             IN            VARCHAR2 DEFAULT NULL
  , p_attribute12             IN            VARCHAR2 DEFAULT NULL
  , p_attribute13             IN            VARCHAR2 DEFAULT NULL
  , p_attribute14             IN            VARCHAR2 DEFAULT NULL
  , p_attribute15             IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category      IN            VARCHAR2 DEFAULT NULL
  , p_date_selected           IN            VARCHAR2 DEFAULT NULL
  , p_category_id             IN            NUMBER DEFAULT NULL
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id         IN            NUMBER DEFAULT NULL
  , p_template_id             IN            NUMBER DEFAULT NULL
  , p_template_group_id       IN            NUMBER DEFAULT NULL
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  , p_task_split_flag         IN            VARCHAR2
  , p_reference_flag          IN            VARCHAR2 DEFAULT NULL
  , p_child_position          IN            VARCHAR2 DEFAULT NULL
  , p_child_sequence_num      IN            NUMBER DEFAULT NULL
  );

  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_name          IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_name        IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_name      IN            VARCHAR2 DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_name         IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_number         IN            VARCHAR2 DEFAULT NULL
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT NULL
  , p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
  , p_timezone_name           IN            VARCHAR2 DEFAULT NULL
  , p_source_object_type_code IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id        IN            NUMBER DEFAULT NULL
  , p_source_object_name      IN            VARCHAR2 DEFAULT NULL
  , p_duration                IN            NUMBER DEFAULT NULL
  , p_duration_uom            IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort          IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort           IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete     IN            NUMBER DEFAULT NULL
  , p_reason_code             IN            VARCHAR2 DEFAULT NULL
  , p_private_flag            IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag            IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag          IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag            IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag           IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id     IN            NUMBER DEFAULT NULL
  , p_notification_flag       IN            VARCHAR2 DEFAULT NULL
  , p_notification_period     IN            NUMBER DEFAULT NULL
  , p_notification_period_uom IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_number      IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id          IN            NUMBER DEFAULT NULL
  , p_alarm_start             IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count             IN            NUMBER DEFAULT NULL
  , p_alarm_interval          IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag               IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag              IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag            IN            VARCHAR2 DEFAULT NULL
  , p_costs                   IN            NUMBER DEFAULT NULL
  , p_currency_code           IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level        IN            VARCHAR2 DEFAULT NULL
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , x_task_id                 OUT NOCOPY    NUMBER
  , p_attribute1              IN            VARCHAR2 DEFAULT NULL
  , p_attribute2              IN            VARCHAR2 DEFAULT NULL
  , p_attribute3              IN            VARCHAR2 DEFAULT NULL
  , p_attribute4              IN            VARCHAR2 DEFAULT NULL
  , p_attribute5              IN            VARCHAR2 DEFAULT NULL
  , p_attribute6              IN            VARCHAR2 DEFAULT NULL
  , p_attribute7              IN            VARCHAR2 DEFAULT NULL
  , p_attribute8              IN            VARCHAR2 DEFAULT NULL
  , p_attribute9              IN            VARCHAR2 DEFAULT NULL
  , p_attribute10             IN            VARCHAR2 DEFAULT NULL
  , p_attribute11             IN            VARCHAR2 DEFAULT NULL
  , p_attribute12             IN            VARCHAR2 DEFAULT NULL
  , p_attribute13             IN            VARCHAR2 DEFAULT NULL
  , p_attribute14             IN            VARCHAR2 DEFAULT NULL
  , p_attribute15             IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category      IN            VARCHAR2 DEFAULT NULL
  , p_date_selected           IN            VARCHAR2 DEFAULT NULL
  , p_category_id             IN            NUMBER DEFAULT NULL
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id         IN            NUMBER DEFAULT NULL
  , p_template_id             IN            NUMBER DEFAULT NULL
  , p_template_group_id       IN            NUMBER DEFAULT NULL
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  );

  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_name          IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_name        IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_name      IN            VARCHAR2 DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_name         IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_number         IN            VARCHAR2 DEFAULT NULL
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT NULL
  , p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
  , p_timezone_name           IN            VARCHAR2 DEFAULT NULL
  , p_source_object_type_code IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id        IN            NUMBER DEFAULT NULL
  , p_source_object_name      IN            VARCHAR2 DEFAULT NULL
  , p_duration                IN            NUMBER DEFAULT NULL
  , p_duration_uom            IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort          IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort           IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete     IN            NUMBER DEFAULT NULL
  , p_reason_code             IN            VARCHAR2 DEFAULT NULL
  , p_private_flag            IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag            IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag          IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag            IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag           IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id     IN            NUMBER DEFAULT NULL
  , p_notification_flag       IN            VARCHAR2 DEFAULT NULL
  , p_notification_period     IN            NUMBER DEFAULT NULL
  , p_notification_period_uom IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_number      IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id          IN            NUMBER DEFAULT NULL
  , p_alarm_start             IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count             IN            NUMBER DEFAULT NULL
  , p_alarm_interval          IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag               IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag              IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag            IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag            IN            VARCHAR2 DEFAULT NULL
  , p_costs                   IN            NUMBER DEFAULT NULL
  , p_currency_code           IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level        IN            VARCHAR2 DEFAULT NULL
  , p_task_assign_tbl         IN            task_assign_tbl DEFAULT g_miss_task_assign_tbl
  , p_task_depends_tbl        IN            task_depends_tbl DEFAULT g_miss_task_depends_tbl
  , p_task_rsrc_req_tbl       IN            task_rsrc_req_tbl DEFAULT g_miss_task_rsrc_req_tbl
  , p_task_refer_tbl          IN            task_refer_tbl DEFAULT g_miss_task_refer_tbl
  , p_task_dates_tbl          IN            task_dates_tbl DEFAULT g_miss_task_dates_tbl
  , p_task_notes_tbl          IN            task_notes_tbl DEFAULT g_miss_task_notes_tbl
  , p_task_recur_rec          IN            task_recur_rec DEFAULT g_miss_task_recur_rec
  , p_task_contacts_tbl       IN            task_contacts_tbl DEFAULT g_miss_task_contacts_tbl
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , x_task_id                 OUT NOCOPY    NUMBER
  , p_attribute1              IN            VARCHAR2 DEFAULT NULL
  , p_attribute2              IN            VARCHAR2 DEFAULT NULL
  , p_attribute3              IN            VARCHAR2 DEFAULT NULL
  , p_attribute4              IN            VARCHAR2 DEFAULT NULL
  , p_attribute5              IN            VARCHAR2 DEFAULT NULL
  , p_attribute6              IN            VARCHAR2 DEFAULT NULL
  , p_attribute7              IN            VARCHAR2 DEFAULT NULL
  , p_attribute8              IN            VARCHAR2 DEFAULT NULL
  , p_attribute9              IN            VARCHAR2 DEFAULT NULL
  , p_attribute10             IN            VARCHAR2 DEFAULT NULL
  , p_attribute11             IN            VARCHAR2 DEFAULT NULL
  , p_attribute12             IN            VARCHAR2 DEFAULT NULL
  , p_attribute13             IN            VARCHAR2 DEFAULT NULL
  , p_attribute14             IN            VARCHAR2 DEFAULT NULL
  , p_attribute15             IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category      IN            VARCHAR2 DEFAULT NULL
  , p_date_selected           IN            VARCHAR2 DEFAULT NULL
  , p_category_id             IN            NUMBER DEFAULT NULL
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id         IN            NUMBER DEFAULT NULL
  , p_template_id             IN            NUMBER DEFAULT NULL
  , p_template_group_id       IN            NUMBER DEFAULT NULL
  );

  /*#
  * Updates an existing task.
  *
  * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
  * @rep:paraminfo {@rep:required}
  * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
  * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
  * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
  * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
  * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
  *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
  *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
  *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
  * @param x_msg_count Number of messages returned in the API message list.
  * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
  * @param p_object_version_number Object version number of the current task record.
  * @rep:paraminfo {@rep:required}
  * @param p_task_id Unique task identifier of task to be updated. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
  * @rep:paraminfo {@rep:required}
  * @param p_task_number Unique task number of task to be updated. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
  * @rep:paraminfo {@rep:required}
  * @param p_task_name Subject of the task.
  * @paraminfo {@rep:precision 80}
  * @param p_task_type_name Task type name. Either type name or <code>p_task_type_id</code> can be passed.
  * @param p_task_type_id Unique task type identifier. This is a foreign key to <code>jtf_task_types_b.task_type_id</code>.
  * @param p_description Optional task description.
  * @paraminfo {@rep:precision 4000}
  * @param p_task_status_name Task status name. Either status name or <code>p_task_status_id</code> can be passed.
  * @param p_task_status_id Unique task status identifier. This is a foreign key to <code>jtf_task_statuses_b.task_status_id</code>.
  * @param p_task_priority_name Task priority name. Either priority name or <code>p_task_priority_id</code> can be passed.
  * @param p_task_priority_id Unique task priority identifier. This is a foreign key to <code>jtf_task_priorities_b.task_priority_id</code>.
  * @param p_owner_type_name No longer in use.
  * @param p_owner_type_code Resource type code for the task owner. A task owner is identified with the task resource type code and task resource identifier, therefore this should be used along with <code>p_owner_id</code>.
  * @param p_owner_id Resource identifier for the task owner. Should be used along with <code>p_owner_type_code</code>.
  * @param p_owner_territory_id Territory identification of the task owner.
  * @param p_assigned_by_name No longer in use.
  * @param p_assigned_by_id No longer in use.
  * @param p_customer_number Unique customer number. Either customer number or <code>p_customer_id</code> can be passed to associate the customer with the task.
  * This is validated against <code>hz_parties.party_number</code>.
  * @param p_customer_id Unique customer identifier. Either customer identifier or <code>p_customer_number</code> can be passed to associate the customer with the task.
  * This is validated against <code>hz_parties.party_id</code>.
  * @param p_cust_account_number Customer account number that can be set on a task with an associated customer. Either customer account number or <code>p_customer_account_id</code> can be passed.
  * This is validated against <code>hz_cust_accounts.account_number</code>.
  * @param p_cust_account_id Unique customer account identifier that can be set on a task with an associated customer. Either customer account identifier or <code>p_customer_account_number</code> can be passed.
  * This is validated against <code>hz_cust_accounts.cust_account_id</code>.
  * @param p_address_number Customer address number that can be set on a task with an associated customer. Either customer address number or <code>p_address_id</code> can be passed.
  * This is validated against <code>hz_party_sites.party_site_number</code>.
  * @param p_address_id Unique customer address identifier that can be set on a task with an associated customer. Either customer address identifier or <code>p_address_number</code> can be passed.
  * This is validated against <code>hz_party_sites.party_site_id</code>.
  * @param p_planned_start_date Planned start date for this task.
  * @param p_planned_end_date Planned end date for this task.
  * @param p_scheduled_start_date Scheduled start date for this task.
  * @param p_scheduled_end_date Scheduled end date for this task.
  * @param p_actual_start_date Actual start date for this task.
  * @param p_actual_end_date Actual end date for this task.
  * @param p_timezone_id Timezone identifier used for this task dates. Either timezone identifier or <code>p_timezone_name</code> can be passed. This is validated against <code>hz_timezones.timezone_id</code>.
  * @param p_timezone_name Timezone name used for this task dates. Either timezone name or <code>p_timezone_id</code> can be passed. This is validated against <code>hz_timezones.global_timezone_name</code>.
  * @param p_source_object_type_code Object code used as the source type for this task. The object code can be either <code>'TASK'</code> for standalone tasks or a registered object with usage of <code>'TASK'</code> for contextual tasks.
  * This is a foreign key to <code>jtf_objects_b.object_code</code>.
  * @param p_source_object_id Unique source object identifier used to identify and validate the task source. This must be provided for any contextual task.
  * @param p_source_object_name No longer in use.
  * @param p_duration Duration of this task. Should be used along with <code>p_duration_uom</code>.
  * @param p_duration_uom Unit of measure for the duration. Should be used along with <code>p_duration</code>.
  * @param p_planned_effort Planned effort for this task. Should be used along with <code>p_planned_effort_uom</code>.
  * @param p_planned_effort_uom Unit of Measure for the planned effort. Should be used along with <code>p_planned_effort</code>.
  * @param p_actual_effort Actual effort exerted for this task. Should be used along with <code>p_actual_effort_uom</code>.
  * @param p_actual_effort_uom Unit of Measure for the actual effort. Should be used along with <code>p_actual_effort</code>.
  * @param p_percentage_complete Percentage of this task completion.
  * @param p_reason_code Reserved for internal use only. Reason code is used to check if the task is automated.
  * @param p_private_flag Flag used to mark this task as a private task. This flag is used by task user interface to limit the task visibility to the task owner and assignee only.
  * @param p_publish_flag Flag used to mark this task as a published task. This flag is used by task user interface to set the task for publishing.
  * @param p_restrict_closure_flag Reserved for internal use only.
  * @param p_multi_booked_flag Reserved for internal use only.
  * @param p_milestone_flag Flag used to mark this task as milestone.
  * @param p_holiday_flag Flag used to mark this task execution during holidays.
  * @param p_billable_flag Flag used to mark this task for billing.
  * @param p_bound_mode_code Reserved for internal use only.
  * @param p_soft_bound_flag Reserved for internal use only.
  * @param p_workflow_process_id Process identifier of last workflow launched.
  * @param p_notification_flag Notification flag used to automatically launch workflow.
  * @param p_notification_period Notification period is the time period after which workflow is sent to the task assignees. Should be used along with <code>p_notification_period_uom</code>.
  * @param p_notification_period_uom Unit of measure for notification period. Should be used along with <code>p_notification_period</code>.
  * @param p_parent_task_number Parent task number for this tasks.  Either parent task number or <code>p_parent_task_number</code> can be passed.
  * @param p_parent_task_id Parent task identifier for this tasks.  Either parent task identifier or <code>p_parent_task_id</code> can be passed.
  * @param p_alarm_start Time when the first alarm is fired. Should be used along with <code>p_alarm_start_uom</code>.
  * @param p_alarm_start_uom Unit of measure for alarm start. Should be used along with <code>p_alarm_start</code>.
  * @param p_alarm_on Indicates is alarm turned on.
  * @param p_alarm_count Total number of alarms.
  * @param p_alarm_fired_count Total number of alarms has been fired.
  * @param p_alarm_interval Alarm firing interval. Should be used along with <code>p_alarm_interval_uom</code>.
  * @param p_alarm_interval_uom Unit of measure for alarm interval. Should be used along with <code>p_alarm_interval</code>.
  * @param p_palm_flag Reserved for internal use only.
  * @param p_wince_flag Reserved for internal use only.
  * @param p_laptop_flag Reserved for internal use only.
  * @param p_device1_flag Reserved for internal use only.
  * @param p_device2_flag Reserved for internal use only.
  * @param p_device3_flag Reserved for internal use only.
  * @param p_costs Reserved for internal use only.
  * @param p_currency_code Reserved for internal use only.
  * @param p_escalation_level Level of escalation used by Escalation Module.
  * @param p_attribute1 Attribute1 of customer flex fields.
  * @param p_attribute2 Attribute2 of customer flex fields.
  * @param p_attribute3 Attribute3 of customer flex fields.
  * @param p_attribute4 Attribute4 of customer flex fields.
  * @param p_attribute5 Attribute5 of customer flex fields.
  * @param p_attribute6 Attribute6 of customer flex fields.
  * @param p_attribute7 Attribute7 of customer flex fields.
  * @param p_attribute8 Attribute8 of customer flex fields.
  * @param p_attribute9 Attribute9 of customer flex fields.
  * @param p_attribute10 Attribute10 of customer flex fields.
  * @param p_attribute11 Attribute11 of customer flex fields.
  * @param p_attribute12 Attribute12 of customer flex fields.
  * @param p_attribute13 Attribute13 of customer flex fields.
  * @param p_attribute14 Attribute14 of customer flex fields.
  * @param p_attribute15 Attribute15 of customer flex fields.
  * @param p_attribute_category Attribute category for the customer flex fields.
  * @param p_date_selected Flag used to select which date pair (Planned, Scheduled, or Actual) will be used as calendar date. The default value is set by profile options.
  * @param p_category_id Reserved unique identifier for personal category defined by resource in their calendar. This is a foreign key to <code>jtf_perz_data.perz_date_id</code>.
  * @param p_show_on_calendar Flag to show task on resource's calendar. The task will only show up on Resource's calendar if this flag is set to <code>'Y'</code> and there is a set of date with time present on task level.
  * This flag is defaulted to <code>'Y'</code> if not passed.
  * @param p_owner_status_id No longer in use.
  * @param p_enable_workflow Flag to enable workflow passed as-is to <code>oracle.apps.jtf.cac.task.updateTask</code> business event.
  * @rep:paraminfo {@rep:required}
  * @param p_abort_workflow Flag to abort workflow passed as-is to <code>oracle.apps.jtf.cac.task.updateTask</code> business event.
  * @rep:paraminfo {@rep:required}
  * @param p_task_split_flag Reserved for internal use only. This flag is used to denote split tasks created by Field Service.
  * @rep:paraminfo {@rep:required}
  * The following two values are currently used:
  * <LI><code>'M'</code> - for a master (parent) task
  * <LI><code>'D'</code> - for a dependent (child) task.
  * @param p_child_position Reserved for internal use only. This flag is used by Field Service to mark child position for split tasks
  * @param p_child_sequence_num Reserved for internal use only. It is used by Field Service to mark child sequence for split tasks
  * @param p_location_id Reserved for internal use only. It is used by Field Service to modify location id in task table
  * @rep:paraminfo {@rep:required}
  *
  * @rep:primaryinstance
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Update Task
  * @rep:compatibility S
  * @rep:businessevent oracle.apps.jtf.cac.task.updateTask
  * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
  * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
  * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
  * @rep:category BUSINESS_ENTITY AMS_LEAD
  */
  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_number             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_name          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_name         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_number         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_timezone_name           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_type_code IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_start             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_attribute1              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id         IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_number      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  , p_task_split_flag         IN            VARCHAR2
  , p_child_position          IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_child_sequence_num      IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_location_id             IN            NUMBER
  );

  -- Simplex Enhancements ..
  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_number             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_name          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_name         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_number         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_timezone_name           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_type_code IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_start             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_attribute1              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id         IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_number      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  , p_task_split_flag         IN            VARCHAR2
  , p_child_position          IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_child_sequence_num      IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  );

  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_number             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_name          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_name         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_number         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_timezone_name           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_type_code IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_start             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_attribute1              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id         IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_number      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  );

  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_number             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_name          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_name         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_number         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  ,   -- from hz_parties
    p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_timezone_name           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_type_code IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag       IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_start             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom      IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_attribute1              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9              IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id             IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id         IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_id          IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_parent_task_number      IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
  * Locks a task.
  *
  * @param p_api_version Standard API version number.
  * @rep:paraminfo {@rep:required}
  * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
  * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
  * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
  *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
  *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
  *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
  * @param x_msg_count Number of messages returned in the API message list.
  * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
  * @param p_object_version_number Object version number of the current task record.
  * @rep:paraminfo {@rep:required}
  * @param p_task_id Unique task identifier of task to be locked.
  * @rep:paraminfo {@rep:required}
  *
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Lock Task
  * @rep:compatibility S
  */
  PROCEDURE lock_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id               IN            NUMBER
  , p_object_version_number IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  );

  PROCEDURE delete_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN            NUMBER
  , p_task_id                   IN            NUMBER DEFAULT NULL
  , p_task_number               IN            VARCHAR2 DEFAULT NULL
  , p_delete_future_recurrences IN            VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  -- New version

  /*# Deletes an existing task.  This API cannot be used to delete tasks that are associated with service requests.  Please note that this is a "soft" deletion where records are marked as deleted but not physically removed from the database.
   *
   * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @rep:paraminfo {@rep:required}
   * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
   * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
   * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
   *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
   *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
   *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
   * @param x_msg_count Number of messages returned in the API message list.
   * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
   * @param p_object_version_number Object version number of the current task record.
   * @rep:paraminfo {@rep:required}
   * @param p_task_id Unique task identifier of task to be deleted. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
   * @rep:paraminfo {@rep:required}
   * @param p_task_number Unique task number of task to be deleted. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
   * @rep:paraminfo {@rep:required}
   * @param p_delete_future_recurrences For internal use only. This flag is used to mark future recurrences to be deleted for repeating appointments.
   * @param p_enable_workflow Flag to enable workflow passed as-is to <code>oracle.apps.jtf.cac.task.deleteTask</code> business event.
   * @rep:paraminfo {@rep:required}
   * @param p_abort_workflow Flag to abort workflow passed as-is to <code>oracle.apps.jtf.cac.task.deleteTask</code> business event.
   * @rep:paraminfo {@rep:required}
   *
   * @rep:primaryinstance
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Delete Task
   * @rep:compatibility S
   * @rep:businessevent oracle.apps.jtf.cac.task.deleteTask
   * @rep:metalink 249665.1 Oracle Common Application Calendar - API Reference Guide
   * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
   * @rep:category BUSINESS_ENTITY AS_OPPORTUNITY
   * @rep:category BUSINESS_ENTITY AMS_LEAD
   */
  PROCEDURE delete_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN            NUMBER
  , p_task_id                   IN            NUMBER DEFAULT NULL
  , p_task_number               IN            VARCHAR2 DEFAULT NULL
  , p_delete_future_recurrences IN            VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
  * Exports the Task's query.
  *
  * @param p_api_version the standard API version number
  * @param p_init_msg_list the standard API flag allows API callers to request
  * that the API does the initialization of the message list on their behalf.
  * By default, the message list will not be initialized.
  * @param p_validate_level the standard API validation level
  * @param x_return_status returns the result of all the operations performed
  * by the API and must have one of the following values:
  *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
  *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
  *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
  * @param x_msg_count returns the number of messages in the API message list
  * @param x_msg_data returns the message in an encoded format if
  * <code>x_msg_count</code> returns number one.
  * @param p_file_name is the file name for exporting task data
  * @param p_task_id is the task id of the task to be queried.
  * @param p_task_number is the task number of the task to be queried.
  * @param p_task_name is the name of the task to be queried.
  * @param p_task_type_name is the type name of the task to be queried
  * @param p_task_type_id is the type id of the task to be queried
  * @param p_description is the description of the task to be queried
  * @param p_task_status_name is the status name of the task to be queried
  * @param p_task_status_id is the status id the of task to be queried
  * @param p_task_priority_name is the priority name of the task to be queried
  * @param p_task_priority_id is the priority id of the task to be queried
  * @param p_owner_type_code is the owner type code of the task to be queried
  * @param p_owner_id is the owner id of the task to be queried
  * @param p_owner_territory_id is owner's territory id of the task to be queried
  * @param p_assigned_by_id is the id of the assignee of the task to be queried
  * @param p_assigned_name is the name of the assignee of the task to be queried
  * @param p_address_id is the customer address id of the task to be queried
  * @param p_customer_number is the customer number of the task to be queried
  * @param p_customer_name is the customer name of the task to be queried
  * @param p_customer_id is the customer id of the task to be queried
  * @param p_cust_account_number is the customer account number of the task to be queried
  * @param p_cust_account_id is the customer account id of the task to be queried
  * @param p_planned_start_date is planned start date of the task to be queried
  * @param p_planned_end_date is planned end date of the task to be queried
  * @param p_scheduled_start_date is scheduled start date of the task to be queried
  * @param p_scheduled_end_date is scheduled end date of the task to be queried
  * @param p_actual_start_date is actual start date of the task to be queried
  * @param p_actual_end_date is actual end date of the task to be queried
  * @param p_object_type_code is the source object type code of the task to be queried
  * @param p_source_object_id is the source object id of the task to be queried
  * @param p_object_name is source object name of the task to be queried
  * @param p_percentage_complete is percent completion of the task to be queried
  * @param p_reason_code is used to check if the task is automated
  * @param p_private_flag is used check if the task created is private
  * @param p_restrict_closure_flag is used for closing purposes by field service
  * @param p_multi_booked_flag is to check multiple bookings by field service
  * @param p_milestone_flag is for setting milestones by field service
  * @param p_holiday_flag is used for setting holidays by field service
  * @param p_workflow_process_id is id of last workflow launched
  * @param p_notification_flag is used for automatically launching workflow
  * @param p_parent_task_id is the task id of parent task of the task being created
  * @param p_alarm_on indicates whether the alarm is on
  * @param p_alarm_count is the total number of alarms
  * @param p_alarm_fired_count is the total number of alarms being fired
  * @param p_ref_object_id is used internally
  * @param p_ref_object_type_code is used internally
  * @param p_sort_data is used internally
  * @param p_start_pointer is used internally
  * @param p_rec_wanted is used internally
  * @param p_show_all is used internally
  * @param p_query_or_next_code is used internally
  * @param x_task_table is used internally
  * @param x_total_retrieved is used internally
  * @param x_total_returned is used internally
  * @param x_object_version_number is the object version number of the current record.
  * @param p_location_id is the location id of the task to be queried.
  *
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Export Task Query
  * @rep:compatibility N
  */
  PROCEDURE export_query_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_file_name             IN            VARCHAR2
  , p_task_number           IN            jtf_tasks_v.task_number%TYPE DEFAULT NULL
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE DEFAULT NULL
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE DEFAULT NULL
  , p_description           IN            jtf_tasks_v.description%TYPE DEFAULT NULL
  , p_task_type_name        IN            jtf_tasks_v.task_type%TYPE DEFAULT NULL
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE DEFAULT NULL
  , p_task_status_name      IN            jtf_tasks_v.task_status%TYPE DEFAULT NULL
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE DEFAULT NULL
  , p_task_priority_name    IN            jtf_tasks_v.task_priority%TYPE DEFAULT NULL
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_assigned_name         IN            jtf_tasks_v.assigned_by_name%TYPE DEFAULT NULL
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE DEFAULT NULL
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_customer_name         IN            jtf_tasks_v.customer_name%TYPE DEFAULT NULL
  , p_customer_number       IN            jtf_tasks_v.customer_number%TYPE DEFAULT NULL
  , p_cust_account_number   IN            jtf_tasks_v.cust_account_number%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE DEFAULT NULL
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE DEFAULT NULL
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE DEFAULT NULL
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE DEFAULT NULL
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE DEFAULT NULL
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE DEFAULT NULL
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE DEFAULT NULL
  , p_object_name           IN            jtf_tasks_v.source_object_name%TYPE DEFAULT NULL
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE DEFAULT NULL
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE DEFAULT NULL
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE DEFAULT NULL
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE DEFAULT NULL
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE DEFAULT NULL
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE DEFAULT NULL
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE DEFAULT NULL
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE DEFAULT NULL
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE DEFAULT NULL
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE DEFAULT NULL
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE DEFAULT NULL
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE DEFAULT NULL
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE DEFAULT NULL
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE DEFAULT NULL
  , p_ref_object_id         IN            NUMBER DEFAULT NULL
  , p_ref_object_type_code  IN            VARCHAR2 DEFAULT NULL
  , p_sort_data             IN            sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  , p_location_id           IN            NUMBER
  );

  PROCEDURE export_query_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_file_name             IN            VARCHAR2
  , p_task_number           IN            jtf_tasks_v.task_number%TYPE DEFAULT NULL
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE DEFAULT NULL
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE DEFAULT NULL
  , p_description           IN            jtf_tasks_v.description%TYPE DEFAULT NULL
  , p_task_type_name        IN            jtf_tasks_v.task_type%TYPE DEFAULT NULL
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE DEFAULT NULL
  , p_task_status_name      IN            jtf_tasks_v.task_status%TYPE DEFAULT NULL
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE DEFAULT NULL
  , p_task_priority_name    IN            jtf_tasks_v.task_priority%TYPE DEFAULT NULL
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_assigned_name         IN            jtf_tasks_v.assigned_by_name%TYPE DEFAULT NULL
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE DEFAULT NULL
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_customer_name         IN            jtf_tasks_v.customer_name%TYPE DEFAULT NULL
  , p_customer_number       IN            jtf_tasks_v.customer_number%TYPE DEFAULT NULL
  , p_cust_account_number   IN            jtf_tasks_v.cust_account_number%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE DEFAULT NULL
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE DEFAULT NULL
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE DEFAULT NULL
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE DEFAULT NULL
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE DEFAULT NULL
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE DEFAULT NULL
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE DEFAULT NULL
  , p_object_name           IN            jtf_tasks_v.source_object_name%TYPE DEFAULT NULL
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE DEFAULT NULL
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE DEFAULT NULL
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE DEFAULT NULL
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE DEFAULT NULL
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE DEFAULT NULL
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE DEFAULT NULL
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE DEFAULT NULL
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE DEFAULT NULL
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE DEFAULT NULL
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE DEFAULT NULL
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE DEFAULT NULL
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE DEFAULT NULL
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE DEFAULT NULL
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE DEFAULT NULL
  , p_ref_object_id         IN            NUMBER DEFAULT NULL
  , p_ref_object_type_code  IN            VARCHAR2 DEFAULT NULL
  , p_sort_data             IN            sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
   * Querys the Task.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_validate_level the standard API validation level.
   * @param x_return_status returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   * @param p_task_id is the task id of the task to be queried.
   * @param p_task_number is the task number of the task to be queried.
   * @param p_task_name is the name of the task to be queried.
   * @param p_task_type_name is the type name of the task to be queried
   * @param p_task_type_id is the type id of the task to be queried
   * @param p_description is the description of the task to be queried
   * @param p_task_status_name is the status name of the task to be queried
   * @param p_task_status_id is the status id the of task to be queried
   * @param p_task_priority_name is the priority name of the task to be queried
   * @param p_task_priority_id is the priority id of the task to be queried
   * @param p_owner_type_code is the owner type code of the task to be queried
   * @param p_owner_id is the owner id of the task to be queried
   * @param p_owner_territory_id is owner's territory id of the task to be queried
   * @param p_assigned_by_id is the id of the assignee of the task to be queried
   * @param p_assigned_name is the name of the assignee of the task to be queried
   * @param p_address_id is the customer address id of the task to be queried
   * @param p_customer_number is the customer number of the task to be queried
   * @param p_customer_id is the customer id of the task to be queried
   * @param p_customer_name is the customer name of the task to be queried
   * @param p_cust_account_number is the customer account number of the task to be queried
   * @param p_cust_account_id is the customer account id of the task to be queried
   * @param p_planned_start_date is planned start date of the task to be queried
   * @param p_planned_end_date is planned end date of the task to be queried
   * @param p_scheduled_start_date is scheduled start date of the task to be queried
   * @param p_scheduled_end_date is scheduled end date of the task to be queried
   * @param p_actual_start_date is actual start date of the task to be queried
   * @param p_actual_end_date is actual end date of the task to be queried
   * @param p_object_type_code is the source object type code of the task to be queried
   * @param p_source_object_id is the source object id of the task to be queried
   * @param p_object_name is source object name of the task to be queried
   * @param p_percentage_complete is percent completion of the task to be queried
   * @param p_reason_code is used to check if the task is automated
   * @param p_private_flag is used to flag a private task
   * @param p_restrict_closure_flag is used for closing purposes by field service
   * @param p_multi_booked_flag is to check multiple bookings by field service
   * @param p_milestone_flag is for setting milestones by field service
   * @param p_holiday_flag is used for setting holidays by field service
   * @param p_workflow_process_id is id of last workflow launched
   * @param p_notification_flag is used for automatically launching workflow
   * @param p_parent_task_id is the task id of parent task of the task being created
   * @param p_alarm_on indicates whether the alarm is on
   * @param p_alarm_count is the total number of alarms
   * @param p_alarm_fired_count is the total number of alarms being fired
   * @param p_ref_object_id is used internally
   * @param p_ref_object_type_code is used internally
   * @param p_sort_data is used internally
   * @param p_start_pointer is used internally
   * @param p_rec_wanted is used internally
   * @param p_show_all is used internally
   * @param p_query_or_next_code is used internally
   * @param x_task_table is used internally
   * @param x_total_retrieved is used internally
   * @param x_total_returned is used internally
   * @param x_object_version_number is the object version number of the current record.
   * @param p_location_id is the location id of the task to be queried
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Query Task
   * @rep:compatibility N
   */
  PROCEDURE query_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_task_number           IN            jtf_tasks_v.task_number%TYPE DEFAULT NULL
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE DEFAULT NULL
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE DEFAULT NULL
  , p_description           IN            jtf_tasks_v.description%TYPE DEFAULT NULL
  , p_task_type_name        IN            jtf_tasks_v.task_type%TYPE DEFAULT NULL
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE DEFAULT NULL
  , p_task_status_name      IN            jtf_tasks_v.task_status%TYPE DEFAULT NULL
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE DEFAULT NULL
  , p_task_priority_name    IN            jtf_tasks_v.task_priority%TYPE DEFAULT NULL
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_assigned_name         IN            jtf_tasks_v.assigned_by_name%TYPE DEFAULT NULL
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE DEFAULT NULL
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_customer_name         IN            jtf_tasks_v.customer_name%TYPE DEFAULT NULL
  , p_customer_number       IN            jtf_tasks_v.customer_number%TYPE DEFAULT NULL
  , p_cust_account_number   IN            jtf_tasks_v.cust_account_number%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE DEFAULT NULL
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE DEFAULT NULL
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE DEFAULT NULL
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE DEFAULT NULL
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE DEFAULT NULL
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE DEFAULT NULL
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE DEFAULT NULL
  , p_object_name           IN            jtf_tasks_v.source_object_name%TYPE DEFAULT NULL
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE DEFAULT NULL
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE DEFAULT NULL
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE DEFAULT NULL
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE DEFAULT NULL
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE DEFAULT NULL
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE DEFAULT NULL
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE DEFAULT NULL
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE DEFAULT NULL
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE DEFAULT NULL
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE DEFAULT NULL
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE DEFAULT NULL
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE DEFAULT NULL
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE DEFAULT NULL
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE DEFAULT NULL
  , p_ref_object_id         IN            NUMBER DEFAULT NULL
  , p_ref_object_type_code  IN            VARCHAR2 DEFAULT NULL
  , p_sort_data             IN            sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  , p_location_id           IN            NUMBER
  );

  PROCEDURE query_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_task_number           IN            jtf_tasks_v.task_number%TYPE DEFAULT NULL
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE DEFAULT NULL
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE DEFAULT NULL
  , p_description           IN            jtf_tasks_v.description%TYPE DEFAULT NULL
  , p_task_type_name        IN            jtf_tasks_v.task_type%TYPE DEFAULT NULL
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE DEFAULT NULL
  , p_task_status_name      IN            jtf_tasks_v.task_status%TYPE DEFAULT NULL
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE DEFAULT NULL
  , p_task_priority_name    IN            jtf_tasks_v.task_priority%TYPE DEFAULT NULL
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_assigned_name         IN            jtf_tasks_v.assigned_by_name%TYPE DEFAULT NULL
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE DEFAULT NULL
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_customer_name         IN            jtf_tasks_v.customer_name%TYPE DEFAULT NULL
  , p_customer_number       IN            jtf_tasks_v.customer_number%TYPE DEFAULT NULL
  , p_cust_account_number   IN            jtf_tasks_v.cust_account_number%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE DEFAULT NULL
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE DEFAULT NULL
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE DEFAULT NULL
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE DEFAULT NULL
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE DEFAULT NULL
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE DEFAULT NULL
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE DEFAULT NULL
  , p_object_name           IN            jtf_tasks_v.source_object_name%TYPE DEFAULT NULL
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE DEFAULT NULL
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE DEFAULT NULL
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE DEFAULT NULL
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE DEFAULT NULL
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE DEFAULT NULL
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE DEFAULT NULL
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE DEFAULT NULL
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE DEFAULT NULL
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE DEFAULT NULL
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE DEFAULT NULL
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE DEFAULT NULL
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE DEFAULT NULL
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE DEFAULT NULL
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE DEFAULT NULL
  , p_ref_object_id         IN            NUMBER DEFAULT NULL
  , p_ref_object_type_code  IN            VARCHAR2 DEFAULT NULL
  , p_sort_data             IN            sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
   * Querys the next Task.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_validate_level the standard validation level used by this API.
   * @param x_return_status returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   * @param p_task_id is the task id of the task to be queried.
   * @p_validate_level is used internally
   * @param p_query_type is the name of the task to be queried.
   * @param p_date_type is the type name of the task to be queried
   * @param p_date_start_or_end is the type id of the task to be queried
   * @param p_owner_type_code is the owner type code of the task to be queried
   * @param p_owner_id is the owner id of the task to be queried
   * @param p_assigned_by is the assignee id of the task to be queried
   * @param p_sort_data is used internally
   * @param p_start_pointer is used internally
   * @param p_rec_wanted is used internally
   * @param p_show_all is used internally
   * @param p_query_or_next_code is used internally
   * @param x_task_table is used internally
   * @param x_total_retrieved is used internally
   * @param x_total_returned is used internally
   * @param x_object_version_number is the object version number of the current record.
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Query Next Task
   * @rep:compatibility N
   */
  PROCEDURE query_next_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE
  ,   -- current task id
    p_query_type            IN            VARCHAR2 DEFAULT 'Dependency'
  ,   -- values Dependency or Date
    p_date_type             IN            VARCHAR2 DEFAULT NULL
  , p_date_start_or_end     IN            VARCHAR2 DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_assigned_by           IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_sort_data             IN            sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2 DEFAULT 'Y'
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
   * Exports the Task to file.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_validate_level the standard validation level used by this API.
   * @param x_return_status returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   * @p_validate_level is used internally
   * @param p_file_name is the name of the file data is exported to
   * @param p_task_table is the table of tasks
   * @param x_object_version_number is the object version number of the current record.
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Task Export
   * @rep:compatibility N
   */
  PROCEDURE export_file(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_validate_level        IN            VARCHAR2 DEFAULT fnd_api.g_valid_level_full
  , p_file_name             IN            VARCHAR2
  , p_task_table            IN            jtf_tasks_pub.task_table_type
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_object_version_number IN OUT NOCOPY NUMBER
  );

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
  * Copys the Task data into another Task.
  *
  * @param p_api_version the standard API version number
  * @param p_init_msg_list the standard API flag allows API callers to request
  * that the API does the initialization of the message list on their behalf.
  * By default, the message list will not be initialized.
  * @param p_commit the standard API flag is used by API callers to ask
  * the API to commit on their behalf after performing its function
  * By default, the commit will not be performed.
  * @param x_return_status returns the result of all the operations performed
  * by the API and must have one of the following values:
  *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
  *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
  *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
  * @param x_msg_count returns the number of messages in the API message list
  * @param x_msg_data returns the message in an encoded format if
  * <code>x_msg_count</code> returns number one.
  * @param p_source_task_id is the source id of the task
  * @param p_source_task_number is the source number of the task
  * @param p_target_task_id is used internally
  * @param p_copy_task_assignments is used internally
  * @param p_copy_task_rsc_reqs is used internally
  * @param p_copy_task_depends is used internally
  * @param p_create_recurrences is used internally
  * @param p_copy_task_references is used internally
  * @param p_copy_task_dates is used internally
  * @param p_copy_notes is used internally
  * @param p_resource_id is resource id of the task owner
  * @param p_resource_type is resource type code of the owner of the task
  * @param x_task_id returns a created task id.
  * @param p_copy_task_contacts is used internally
  * @param p_copy_task_contact_points is used internally
  *
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Copy Task
  * @rep:compatibility N
  */
  PROCEDURE copy_task(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                   IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_source_task_id           IN            NUMBER DEFAULT NULL
  , p_source_task_number       IN            VARCHAR2 DEFAULT NULL
  , p_target_task_id           IN            NUMBER DEFAULT NULL
  , p_copy_task_assignments    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_copy_task_rsc_reqs       IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_copy_task_depends        IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_create_recurrences       IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_copy_task_references     IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_copy_task_dates          IN            VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status            OUT NOCOPY    VARCHAR2
  , p_copy_notes               IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_resource_id              IN            NUMBER DEFAULT NULL
  , p_resource_type            IN            VARCHAR2 DEFAULT NULL
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , x_task_id                  OUT NOCOPY    NUMBER
  , p_copy_task_contacts       IN            VARCHAR2 DEFAULT jtf_task_utl.g_false_char
  , p_copy_task_contact_points IN            VARCHAR2 DEFAULT jtf_task_utl.g_false_char
  );

  TYPE task_details_tbl IS TABLE OF task_details_rec
    INDEX BY BINARY_INTEGER;

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /*
     * Creates a Task by using the Task Template.
     * This method is deperecated and will be soon obsolete.
     * Please use jtf_task_inst_templates_pub.create_task_from_template instead.
     *
     * @param p_api_version The standard API version number.
     * @param p_init_msg_list The standard API flag allows API callers to request
     * that the API does the initialization of the message list on their behalf.
     * By default, the message list will not be initialized.
     * @param p_commit The standard API flag is used by API callers to ask
     * the API to commit on their behalf after performing its function.
     * By default, the commit will not be performed.
     * @param x_return_status Returns the result of all the operations performed
     * by the API and must have one of the following values:
     *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
     *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
     *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>.
     * @param x_msg_count Returns the number of messages in the API message list.
     * @param x_msg_data Returns the message in an encoded format if
     * <code>x_msg_count</code> returns number one.
     * @param x_task_details_tbl Returns the Task Ids of the tasks created.
     * @param p_task_template_group_id This is group id of Task Templates used for creating tasks.
     * @param p_task_template_group_name This is group name of Task Templates used for creating tasks.
     * @param p_owner_type_code This is the owner type code of the task to be created.
     * @param p_owner_id This is the owner id of the task to be created.
     * @param p_assigned_by_id This is the id of the assignee of the task to be created.
     * @param p_customer_id This is the customer id of the task to be created.
     * @param p_cust_account_id This is the customer account id of the task to be created.
     * @param p_address_id This is the address id of the customer of the task to be created.
     * @param p_planned_start_date This is planned start date of the task to be created.
     * @param p_planned_end_date This is planned end date of the task to be created.
     * @param p_scheduled_start_date This is scheduled start date of the task to be created.
     * @param p_scheduled_end_date This is scheduled end date of the task to be created.
     * @param p_actual_start_date This is actual start date of the task to be created.
     * @param p_actual_end_date This is actual end date of the task to be created.
     * @param p_timezone_id This is timezone id of the task to be created.
     * @param p_source_object_id This is the source object id of the task to be created.
     * @param p_source_object_name This is source object name of the task to be created.
     * @param p_actual_effort This is actual effort of the task to be created.
     * @param p_actual_effort_uom This is the unit of measure of the actual effort of the task to be created.
     * @param p_percentage_complete This is percent completion of the task to be created.
     * @param p_reason_code This is used to check if the task is automated.
     * @param p_bound_mode_code This is used internally.
     * @param p_soft_bound_flag This is used internally.
     * @param p_workflow_process_id This is id of last workflow launched.
     * @param p_parent_task_id This is the task id of parent task of the task being created.
     * @param p_palm_flag This is used by Mobile Services.
     * @param p_wince_flag This is used by Mobile Services.
     * @param p_laptop_flag This is used by Mobile Services.
     * @param p_device1_flag This is used by Mobile Services.
     * @param p_device2_flag This is used by Mobile Services.
     * @param p_device3_flag This is used by Mobile Services.
     * @param P_OWNER_TERRITORY_ID This is a territory of the task owner.
     * @param p_costs This is for internal use only.
     * @param p_currency_code This is for internal use only.
     * @param p_attribute1 This is used for descriptive felxfield column.
     * @param p_attribute2 This is used for descriptive felxfield column.
     * @param p_attribute3 This is used for descriptive felxfield column.
     * @param p_attribute4 This is used for descriptive felxfield column.
     * @param p_attribute5 This is used for descriptive felxfield column.
     * @param p_attribute6 This is used for descriptive felxfield column.
     * @param p_attribute7 This is used for descriptive felxfield column.
     * @param p_attribute8 This is used for descriptive felxfield column.
     * @param p_attribute9 This is used for descriptive felxfield column.
     * @param p_attribute10 This is used for descriptive felxfield column.
     * @param p_attribute11 This is used for descriptive felxfield column.
     * @param p_attribute12 This is used for descriptive felxfield column.
     * @param p_attribute13 This is used for descriptive felxfield column.
     * @param p_attribute14 This is used for descriptive felxfield column.
     * @param p_attribute15 This is used for descriptive felxfield column.
     * @param p_attribute_category This is used for descriptive felxfield column.
     * @param p_date_selected This is populated from profile options to update Calendar dates.
     * @param p_location_id Reserved for internal use only. It is used by Field Service to store location id in task table.
     *
     * @rep:scope public
     * @rep:lifecycle deprecated
     * @rep:displayname Create Task From Template
     * @rep:compatibility N
     */
  PROCEDURE create_task_from_template(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                   IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_template_group_id   IN            NUMBER DEFAULT NULL
  , p_task_template_group_name IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code          IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                 IN            NUMBER DEFAULT NULL
  , p_source_object_id         IN            NUMBER DEFAULT NULL
  , p_source_object_name       IN            VARCHAR2 DEFAULT NULL
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , x_task_details_tbl         OUT NOCOPY    task_details_tbl
  , p_assigned_by_id           IN            NUMBER DEFAULT NULL
  , p_cust_account_id          IN            NUMBER DEFAULT NULL
  , p_customer_id              IN            NUMBER DEFAULT NULL
  , p_address_id               IN            NUMBER DEFAULT NULL
  , p_actual_start_date        IN            DATE DEFAULT NULL
  , p_actual_end_date          IN            DATE DEFAULT NULL
  , p_planned_start_date       IN            DATE DEFAULT NULL
  , p_planned_end_date         IN            DATE DEFAULT NULL
  , p_scheduled_start_date     IN            DATE DEFAULT NULL
  , p_scheduled_end_date       IN            DATE DEFAULT NULL
  , p_palm_flag                IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag               IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag             IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id           IN            NUMBER DEFAULT NULL
  , p_percentage_complete      IN            NUMBER DEFAULT NULL
  , p_timezone_id              IN            NUMBER DEFAULT NULL
  , p_actual_effort            IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom        IN            VARCHAR2 DEFAULT NULL
  , p_reason_code              IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code          IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag          IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id      IN            NUMBER DEFAULT NULL
  , p_owner_territory_id       IN            NUMBER DEFAULT NULL
  , p_costs                    IN            NUMBER DEFAULT NULL
  , p_currency_code            IN            VARCHAR2 DEFAULT NULL
  , p_attribute1               IN            VARCHAR2 DEFAULT NULL
  , p_attribute2               IN            VARCHAR2 DEFAULT NULL
  , p_attribute3               IN            VARCHAR2 DEFAULT NULL
  , p_attribute4               IN            VARCHAR2 DEFAULT NULL
  , p_attribute5               IN            VARCHAR2 DEFAULT NULL
  , p_attribute6               IN            VARCHAR2 DEFAULT NULL
  , p_attribute7               IN            VARCHAR2 DEFAULT NULL
  , p_attribute8               IN            VARCHAR2 DEFAULT NULL
  , p_attribute9               IN            VARCHAR2 DEFAULT NULL
  , p_attribute10              IN            VARCHAR2 DEFAULT NULL
  , p_attribute11              IN            VARCHAR2 DEFAULT NULL
  , p_attribute12              IN            VARCHAR2 DEFAULT NULL
  , p_attribute13              IN            VARCHAR2 DEFAULT NULL
  , p_attribute14              IN            VARCHAR2 DEFAULT NULL
  , p_attribute15              IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category       IN            VARCHAR2 DEFAULT NULL
  , p_date_selected            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_location_id              IN            NUMBER
  );

  PROCEDURE create_task_from_template(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                   IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_template_group_id   IN            NUMBER DEFAULT NULL
  , p_task_template_group_name IN            VARCHAR2 DEFAULT NULL
  , p_owner_type_code          IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                 IN            NUMBER DEFAULT NULL
  , p_source_object_id         IN            NUMBER DEFAULT NULL
  , p_source_object_name       IN            VARCHAR2 DEFAULT NULL
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , x_task_details_tbl         OUT NOCOPY    task_details_tbl
  , p_assigned_by_id           IN            NUMBER DEFAULT NULL
  , p_cust_account_id          IN            NUMBER DEFAULT NULL
  , p_customer_id              IN            NUMBER DEFAULT NULL
  , p_address_id               IN            NUMBER DEFAULT NULL
  , p_actual_start_date        IN            DATE DEFAULT NULL
  , p_actual_end_date          IN            DATE DEFAULT NULL
  , p_planned_start_date       IN            DATE DEFAULT NULL
  , p_planned_end_date         IN            DATE DEFAULT NULL
  , p_scheduled_start_date     IN            DATE DEFAULT NULL
  , p_scheduled_end_date       IN            DATE DEFAULT NULL
  , p_palm_flag                IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag               IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag             IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag             IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id           IN            NUMBER DEFAULT NULL
  , p_percentage_complete      IN            NUMBER DEFAULT NULL
  , p_timezone_id              IN            NUMBER DEFAULT NULL
  , p_actual_effort            IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom        IN            VARCHAR2 DEFAULT NULL
  , p_reason_code              IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code          IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag          IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id      IN            NUMBER DEFAULT NULL
  , p_owner_territory_id       IN            NUMBER DEFAULT NULL
  , p_costs                    IN            NUMBER DEFAULT NULL
  , p_currency_code            IN            VARCHAR2 DEFAULT NULL
  , p_attribute1               IN            VARCHAR2 DEFAULT NULL
  , p_attribute2               IN            VARCHAR2 DEFAULT NULL
  , p_attribute3               IN            VARCHAR2 DEFAULT NULL
  , p_attribute4               IN            VARCHAR2 DEFAULT NULL
  , p_attribute5               IN            VARCHAR2 DEFAULT NULL
  , p_attribute6               IN            VARCHAR2 DEFAULT NULL
  , p_attribute7               IN            VARCHAR2 DEFAULT NULL
  , p_attribute8               IN            VARCHAR2 DEFAULT NULL
  , p_attribute9               IN            VARCHAR2 DEFAULT NULL
  , p_attribute10              IN            VARCHAR2 DEFAULT NULL
  , p_attribute11              IN            VARCHAR2 DEFAULT NULL
  , p_attribute12              IN            VARCHAR2 DEFAULT NULL
  , p_attribute13              IN            VARCHAR2 DEFAULT NULL
  , p_attribute14              IN            VARCHAR2 DEFAULT NULL
  , p_attribute15              IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category       IN            VARCHAR2 DEFAULT NULL
  , p_date_selected            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  );

  -- Removed '#' to de-annotate this function. irep parser
  -- will no longer pick up this annotation. Bug# 5406214

  /*
   * Checks task name length when it is used as a parameter.
   *
   * @param p_task_name is the name of the task
   * @param p_message_name is used internally
   * @param p_length is used internally
   * @return p_task_name or error.
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Check Parameter Length
   * @rep:compatibility N
   */
  FUNCTION check_param_length(
    p_task_name    IN VARCHAR2
  , p_message_name IN VARCHAR2 DEFAULT NULL
  , p_length       IN NUMBER DEFAULT 80
  )
    RETURN VARCHAR2;

  -- Removed '#' to de-annotate this procedure. irep parser
  -- will not pick up this annotation. Bug# 5406214

  /* Deletes split task(s). This method can be used only for split tasks. When a master (parent) task is provided, it will delete all dependent tasks (chuildren) along with the master task
  *
  * @param p_api_version the standard API version number
  * @param p_init_msg_list the standard API flag allows API callers to request
  * that the API does the initialization of the message list on their behalf.
  * By default, the message list will not be initialized.
  * @param p_commit the standard API flag is used by API callers to ask
  * the API to commit on their behalf after performing its function
  * By default, the commit will not be performed.
  * @param x_return_status returns the result of all the operations performed
  * by the API and must have one of the following values:
  *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
  *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
  *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
  * @param x_msg_count returns the number of messages in the API message list
  * @param x_msg_data returns the message in an encoded format if
  * <code>x_msg_count</code> returns number one.
  * @param p_task_id is the Task Id of the task being deleted
  * @param p_object_version_number is the object version number of the current record.
  * @param p_try_to_reconnect_flag when this flag is set to Y, the API will try to reconnect tasks after deleting. It should be used only for dependent tasks.
  * @param p_task_split_flag the flag that is used to distinguish between a master (M) and dependent (D) tasks.
  * @param p_template_flag the flag that should be used if provided p_task_id is a template
  *
  * @rep:scope internal
  * @rep:lifecycle active
  * @rep:displayname Delete Split Tasks
  * @rep:compatibility S
  */
  PROCEDURE delete_split_tasks(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number IN            NUMBER
  , p_task_id               IN            NUMBER DEFAULT NULL
  , p_task_split_flag       IN            VARCHAR2 DEFAULT NULL
  , p_try_to_reconnect_flag IN            VARCHAR2 DEFAULT 'N'
  , p_template_flag         IN            VARCHAR2 DEFAULT 'N'
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  PROCEDURE MASS_TASK_UPDATE  (
       P_API_VERSION                   IN     NUMBER
      ,P_INIT_MSG_LIST                 IN     VARCHAR2
      ,P_COMMIT                        IN     VARCHAR2
      ,P_TASK_ID_LIST                  IN     JTF_NUMBER_TABLE
      ,P_NEW_TASK_STATUS_ID            IN     NUMBER
      ,P_NEW_SOURCE_TYPE_CODE          IN     VARCHAR2
      ,P_NEW_SOURCE_VALUE              IN     VARCHAR2
      ,P_NEW_SOURCE_ID                 IN     VARCHAR2
      ,P_NEW_TASK_OWNER_TYPE_CODE      IN     VARCHAR2
      ,P_NEW_TASK_OWNER_ID             IN     NUMBER
      ,P_NEW_PLANNED_START_DATE        IN     DATE
      ,P_NEW_PLANNED_END_DATE          IN     DATE
      ,P_NEW_ACTUAL_START_DATE         IN     DATE
      ,P_NEW_ACTUAL_END_DATE           IN     DATE
      ,P_NEW_SCHEDULED_START_DATE      IN     DATE
      ,P_NEW_SCHEDULED_END_DATE        IN     DATE
      ,P_NEW_CALENDAR_START_DATE       IN     DATE
      ,P_NEW_CALENDAR_END_DATE         IN     DATE
      ,P_NOTE_TYPE                     IN     VARCHAR2
      ,P_NOTE_STATUS                   IN     VARCHAR2
      ,P_NOTE                          IN     VARCHAR2
      ,P_REMOVE_ASSIGNMENT_FLAG        IN     VARCHAR2
      ,X_RETURN_STATUS                 OUT    NOCOPY VARCHAR2
      ,X_MSG_COUNT                     OUT    NOCOPY NUMBER
      ,X_MSG_DATA                      OUT    NOCOPY VARCHAR2
      ,X_SUCC_TASK_ID_LIST             OUT    NOCOPY JTF_NUMBER_TABLE
      ,X_FAILED_TASK_ID_LIST           OUT    NOCOPY JTF_NUMBER_TABLE
      ,X_FAILED_REASON_LIST            OUT    NOCOPY JTF_VARCHAR2_TABLE_2000
  );
END;

/
