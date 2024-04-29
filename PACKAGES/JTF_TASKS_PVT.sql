--------------------------------------------------------
--  DDL for Package JTF_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_PVT" AUTHID CURRENT_USER AS
  /* $Header: jtfvtkts.pls 120.4 2008/03/26 08:14:10 venjayar ship $ */
  g_enable_workflow CONSTANT VARCHAR2(1) := fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW');
  g_abort_workflow  CONSTANT VARCHAR2(1) := fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF');

  --Created for BES enh 2391065
  TYPE task_rec_type IS RECORD(
    task_id                 jtf_tasks_b.task_id%TYPE                   := NULL
  , template_id             jtf_tasks_b.template_id%TYPE               := NULL
  , task_audit_id           jtf_task_audits_b.task_audit_id%TYPE       := NULL
  , task_type_id            jtf_tasks_b.task_type_id%TYPE              := NULL
  , task_status_id          jtf_tasks_b.task_status_id%TYPE            := NULL
  , task_priority_id        jtf_tasks_b.task_priority_id%TYPE          := NULL
  , planned_start_date      jtf_tasks_b.planned_start_date%TYPE        := NULL
  , planned_end_date        jtf_tasks_b.planned_end_date%TYPE          := NULL
  , scheduled_start_date    jtf_tasks_b.scheduled_start_date%TYPE      := NULL
  , scheduled_end_date      jtf_tasks_b.scheduled_end_date%TYPE        := NULL
  , actual_start_date       jtf_tasks_b.actual_start_date%TYPE         := NULL
  , actual_end_date         jtf_tasks_b.actual_end_date%TYPE           := NULL
  , source_object_type_code jtf_tasks_b.source_object_type_code%TYPE   := NULL
  , source_object_id        jtf_tasks_b.source_object_id%TYPE          := NULL
  , enable_workflow         VARCHAR2(1)                                := NULL
  , abort_workflow          VARCHAR2(1)                                := NULL
  );

  -- The overloaded version which added p_enable_workflow and p_abort_workflow
  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
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

  -- The overloaded version which added p_entity and p_free_busy_type
  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
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
  , p_entity                  IN            VARCHAR2
  , p_free_busy_type          IN            VARCHAR2
  );

  -- The overloaded version with Location Id.
  PROCEDURE create_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                   IN            NUMBER DEFAULT NULL
  , p_task_name                 IN            VARCHAR2
  , p_task_type_id              IN            NUMBER DEFAULT NULL
  , p_description               IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id            IN            NUMBER DEFAULT NULL
  , p_task_priority_id          IN            NUMBER DEFAULT NULL
  , p_owner_type_code           IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                  IN            NUMBER DEFAULT NULL
  , p_owner_territory_id        IN            NUMBER DEFAULT NULL
  , p_assigned_by_id            IN            NUMBER DEFAULT NULL
  , p_customer_id               IN            NUMBER DEFAULT NULL
  , p_cust_account_id           IN            NUMBER DEFAULT NULL
  , p_address_id                IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_planned_start_date        IN            DATE DEFAULT NULL
  , p_planned_end_date          IN            DATE DEFAULT NULL
  , p_scheduled_start_date      IN            DATE DEFAULT NULL
  , p_scheduled_end_date        IN            DATE DEFAULT NULL
  , p_actual_start_date         IN            DATE DEFAULT NULL
  , p_actual_end_date           IN            DATE DEFAULT NULL
  , p_timezone_id               IN            NUMBER DEFAULT NULL
  , p_source_object_type_code   IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id          IN            NUMBER DEFAULT NULL
  , p_source_object_name        IN            VARCHAR2 DEFAULT NULL
  , p_duration                  IN            NUMBER DEFAULT NULL
  , p_duration_uom              IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort            IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom        IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort             IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom         IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete       IN            NUMBER DEFAULT NULL
  , p_reason_code               IN            VARCHAR2 DEFAULT NULL
  , p_private_flag              IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag              IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag     IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag         IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag            IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag              IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag             IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code           IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag           IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id       IN            NUMBER DEFAULT NULL
  , p_notification_flag         IN            VARCHAR2 DEFAULT NULL
  , p_notification_period       IN            NUMBER DEFAULT NULL
  , p_notification_period_uom   IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id            IN            NUMBER DEFAULT NULL
  , p_alarm_start               IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom           IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                  IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count               IN            NUMBER DEFAULT NULL
  , p_alarm_interval            IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom        IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag                 IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag                IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag               IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag              IN            VARCHAR2 DEFAULT NULL
  , p_costs                     IN            NUMBER DEFAULT NULL
  , p_currency_code             IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level          IN            VARCHAR2 DEFAULT NULL
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , x_task_id                   OUT NOCOPY    NUMBER
  , p_attribute1                IN            VARCHAR2 DEFAULT NULL
  , p_attribute2                IN            VARCHAR2 DEFAULT NULL
  , p_attribute3                IN            VARCHAR2 DEFAULT NULL
  , p_attribute4                IN            VARCHAR2 DEFAULT NULL
  , p_attribute5                IN            VARCHAR2 DEFAULT NULL
  , p_attribute6                IN            VARCHAR2 DEFAULT NULL
  , p_attribute7                IN            VARCHAR2 DEFAULT NULL
  , p_attribute8                IN            VARCHAR2 DEFAULT NULL
  , p_attribute9                IN            VARCHAR2 DEFAULT NULL
  , p_attribute10               IN            VARCHAR2 DEFAULT NULL
  , p_attribute11               IN            VARCHAR2 DEFAULT NULL
  , p_attribute12               IN            VARCHAR2 DEFAULT NULL
  , p_attribute13               IN            VARCHAR2 DEFAULT NULL
  , p_attribute14               IN            VARCHAR2 DEFAULT NULL
  , p_attribute15               IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category        IN            VARCHAR2 DEFAULT NULL
  , p_date_selected             IN            VARCHAR2 DEFAULT NULL
  , p_category_id               IN            NUMBER DEFAULT NULL
  , p_show_on_calendar          IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id           IN            NUMBER DEFAULT NULL
  , p_template_id               IN            NUMBER DEFAULT NULL
  , p_template_group_id         IN            NUMBER DEFAULT NULL
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  , p_entity                    IN            VARCHAR2
  , p_free_busy_type            IN            VARCHAR2
  , p_task_confirmation_status  IN            VARCHAR2
  , p_task_confirmation_counter IN            NUMBER
  , p_task_split_flag           IN            VARCHAR2
  , p_reference_flag            IN            VARCHAR2 DEFAULT NULL
  , p_child_position            IN            VARCHAR2 DEFAULT NULL
  , p_child_sequence_num        IN            NUMBER DEFAULT NULL
  , p_location_id               IN            NUMBER
  , p_copied_from_task_id       IN            NUMBER DEFAULT NULL
  );

  -- The overloaded version with Simplex Changes.
  PROCEDURE create_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                   IN            NUMBER DEFAULT NULL
  , p_task_name                 IN            VARCHAR2
  , p_task_type_id              IN            NUMBER DEFAULT NULL
  , p_description               IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id            IN            NUMBER DEFAULT NULL
  , p_task_priority_id          IN            NUMBER DEFAULT NULL
  , p_owner_type_code           IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                  IN            NUMBER DEFAULT NULL
  , p_owner_territory_id        IN            NUMBER DEFAULT NULL
  , p_assigned_by_id            IN            NUMBER DEFAULT NULL
  , p_customer_id               IN            NUMBER DEFAULT NULL
  , p_cust_account_id           IN            NUMBER DEFAULT NULL
  , p_address_id                IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_planned_start_date        IN            DATE DEFAULT NULL
  , p_planned_end_date          IN            DATE DEFAULT NULL
  , p_scheduled_start_date      IN            DATE DEFAULT NULL
  , p_scheduled_end_date        IN            DATE DEFAULT NULL
  , p_actual_start_date         IN            DATE DEFAULT NULL
  , p_actual_end_date           IN            DATE DEFAULT NULL
  , p_timezone_id               IN            NUMBER DEFAULT NULL
  , p_source_object_type_code   IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id          IN            NUMBER DEFAULT NULL
  , p_source_object_name        IN            VARCHAR2 DEFAULT NULL
  , p_duration                  IN            NUMBER DEFAULT NULL
  , p_duration_uom              IN            VARCHAR2 DEFAULT NULL
  , p_planned_effort            IN            NUMBER DEFAULT NULL
  , p_planned_effort_uom        IN            VARCHAR2 DEFAULT NULL
  , p_actual_effort             IN            NUMBER DEFAULT NULL
  , p_actual_effort_uom         IN            VARCHAR2 DEFAULT NULL
  , p_percentage_complete       IN            NUMBER DEFAULT NULL
  , p_reason_code               IN            VARCHAR2 DEFAULT NULL
  , p_private_flag              IN            VARCHAR2 DEFAULT NULL
  , p_publish_flag              IN            VARCHAR2 DEFAULT NULL
  , p_restrict_closure_flag     IN            VARCHAR2 DEFAULT NULL
  , p_multi_booked_flag         IN            VARCHAR2 DEFAULT NULL
  , p_milestone_flag            IN            VARCHAR2 DEFAULT NULL
  , p_holiday_flag              IN            VARCHAR2 DEFAULT NULL
  , p_billable_flag             IN            VARCHAR2 DEFAULT NULL
  , p_bound_mode_code           IN            VARCHAR2 DEFAULT NULL
  , p_soft_bound_flag           IN            VARCHAR2 DEFAULT NULL
  , p_workflow_process_id       IN            NUMBER DEFAULT NULL
  , p_notification_flag         IN            VARCHAR2 DEFAULT NULL
  , p_notification_period       IN            NUMBER DEFAULT NULL
  , p_notification_period_uom   IN            VARCHAR2 DEFAULT NULL
  , p_parent_task_id            IN            NUMBER DEFAULT NULL
  , p_alarm_start               IN            NUMBER DEFAULT NULL
  , p_alarm_start_uom           IN            VARCHAR2 DEFAULT NULL
  , p_alarm_on                  IN            VARCHAR2 DEFAULT NULL
  , p_alarm_count               IN            NUMBER DEFAULT NULL
  , p_alarm_interval            IN            NUMBER DEFAULT NULL
  , p_alarm_interval_uom        IN            VARCHAR2 DEFAULT NULL
  , p_palm_flag                 IN            VARCHAR2 DEFAULT NULL
  , p_wince_flag                IN            VARCHAR2 DEFAULT NULL
  , p_laptop_flag               IN            VARCHAR2 DEFAULT NULL
  , p_device1_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device2_flag              IN            VARCHAR2 DEFAULT NULL
  , p_device3_flag              IN            VARCHAR2 DEFAULT NULL
  , p_costs                     IN            NUMBER DEFAULT NULL
  , p_currency_code             IN            VARCHAR2 DEFAULT NULL
  , p_escalation_level          IN            VARCHAR2 DEFAULT NULL
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , x_task_id                   OUT NOCOPY    NUMBER
  , p_attribute1                IN            VARCHAR2 DEFAULT NULL
  , p_attribute2                IN            VARCHAR2 DEFAULT NULL
  , p_attribute3                IN            VARCHAR2 DEFAULT NULL
  , p_attribute4                IN            VARCHAR2 DEFAULT NULL
  , p_attribute5                IN            VARCHAR2 DEFAULT NULL
  , p_attribute6                IN            VARCHAR2 DEFAULT NULL
  , p_attribute7                IN            VARCHAR2 DEFAULT NULL
  , p_attribute8                IN            VARCHAR2 DEFAULT NULL
  , p_attribute9                IN            VARCHAR2 DEFAULT NULL
  , p_attribute10               IN            VARCHAR2 DEFAULT NULL
  , p_attribute11               IN            VARCHAR2 DEFAULT NULL
  , p_attribute12               IN            VARCHAR2 DEFAULT NULL
  , p_attribute13               IN            VARCHAR2 DEFAULT NULL
  , p_attribute14               IN            VARCHAR2 DEFAULT NULL
  , p_attribute15               IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category        IN            VARCHAR2 DEFAULT NULL
  , p_date_selected             IN            VARCHAR2 DEFAULT NULL
  , p_category_id               IN            NUMBER DEFAULT NULL
  , p_show_on_calendar          IN            VARCHAR2 DEFAULT NULL
  , p_owner_status_id           IN            NUMBER DEFAULT NULL
  , p_template_id               IN            NUMBER DEFAULT NULL
  , p_template_group_id         IN            NUMBER DEFAULT NULL
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  , p_entity                    IN            VARCHAR2
  , p_free_busy_type            IN            VARCHAR2
  , p_task_confirmation_status  IN            VARCHAR2
  , p_task_confirmation_counter IN            NUMBER
  , p_task_split_flag           IN            VARCHAR2
  , p_reference_flag            IN            VARCHAR2 DEFAULT NULL
  , p_child_position            IN            VARCHAR2 DEFAULT NULL
  , p_child_sequence_num        IN            NUMBER DEFAULT NULL
  );

  -- old version
  PROCEDURE create_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id                 IN            NUMBER DEFAULT NULL
  , p_task_name               IN            VARCHAR2
  , p_task_type_id            IN            NUMBER DEFAULT NULL
  , p_description             IN            VARCHAR2 DEFAULT NULL
  , p_task_status_id          IN            NUMBER DEFAULT NULL
  , p_task_priority_id        IN            NUMBER DEFAULT NULL
  , p_owner_type_code         IN            VARCHAR2 DEFAULT NULL
  , p_owner_id                IN            NUMBER DEFAULT NULL
  , p_owner_territory_id      IN            NUMBER DEFAULT NULL
  , p_assigned_by_id          IN            NUMBER DEFAULT NULL
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT NULL
  , p_planned_end_date        IN            DATE DEFAULT NULL
  , p_scheduled_start_date    IN            DATE DEFAULT NULL
  , p_scheduled_end_date      IN            DATE DEFAULT NULL
  , p_actual_start_date       IN            DATE DEFAULT NULL
  , p_actual_end_date         IN            DATE DEFAULT NULL
  , p_timezone_id             IN            NUMBER DEFAULT NULL
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
  );

  -- This now supports to update the repeating appointments
  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_parent_task_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  , p_change_mode             IN            VARCHAR2
  );

  -- The overloaded version which added p_enable_workflow and p_abort_workflow
  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_parent_task_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  , p_change_mode             IN            VARCHAR2
  , p_free_busy_type          IN            VARCHAR2
  );

  --Location Id Enhancements....
  PROCEDURE update_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN OUT NOCOPY NUMBER
  , p_task_id                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name                 IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                  IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date          IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date           IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_type_code   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                  IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_parent_task_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                  IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag                 IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , p_attribute1                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id               IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar          IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id           IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  , p_change_mode               IN            VARCHAR2
  , p_free_busy_type            IN            VARCHAR2
  , p_task_confirmation_status  IN            VARCHAR2
  , p_task_confirmation_counter IN            NUMBER
  , p_task_split_flag           IN            VARCHAR2
  , p_child_position            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_child_sequence_num        IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_location_id               IN            NUMBER
  );

  --Simplex Enhancements....
  PROCEDURE update_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN OUT NOCOPY NUMBER
  , p_task_id                   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name                 IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                  IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id           IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date          IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date           IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_type_code   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_source_object_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_source_object_name        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_duration                  IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_duration_uom              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_planned_effort            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_planned_effort_uom        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_actual_effort             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_actual_effort_uom         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_percentage_complete       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_reason_code               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_private_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_publish_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_restrict_closure_flag     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_multi_booked_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_milestone_flag            IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_holiday_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_billable_flag             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_bound_mode_code           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_soft_bound_flag           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_workflow_process_id       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_flag         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_notification_period       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_notification_period_uom   IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_parent_task_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_start_uom           IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_on                  IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_alarm_count               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_fired_count         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_alarm_interval_uom        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_palm_flag                 IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_wince_flag                IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_laptop_flag               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device1_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device2_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_device3_flag              IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_costs                     IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_currency_code             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_escalation_level          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , p_attribute1                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9                IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15               IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category        IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_date_selected             IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_category_id               IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_show_on_calendar          IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_owner_status_id           IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  , p_change_mode               IN            VARCHAR2
  , p_free_busy_type            IN            VARCHAR2
  , p_task_confirmation_status  IN            VARCHAR2
  , p_task_confirmation_counter IN            NUMBER
  , p_task_split_flag           IN            VARCHAR2
  , p_child_position            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_child_sequence_num        IN            NUMBER DEFAULT jtf_task_utl.g_miss_number
  );

  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_parent_task_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  );

  -- old version
  PROCEDURE update_task(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name               IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_description             IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_status_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_priority_id        IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_type_code         IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_owner_id                IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_owner_territory_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_assigned_by_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  ,   ---- hz_party_sites
    p_planned_start_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_planned_end_date        IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_start_date    IN            DATE DEFAULT fnd_api.g_miss_date
  , p_scheduled_end_date      IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_start_date       IN            DATE DEFAULT fnd_api.g_miss_date
  , p_actual_end_date         IN            DATE DEFAULT fnd_api.g_miss_date
  , p_timezone_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  , p_parent_task_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
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
  );

  -- The overloaded version which added p_enable_workflow and p_abort_workflow
  PROCEDURE delete_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN            NUMBER
  , p_task_id                   IN            NUMBER
  , p_delete_future_recurrences IN            VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  , p_enable_workflow           IN            VARCHAR2
  , p_abort_workflow            IN            VARCHAR2
  );

  -- Old version
  PROCEDURE delete_task(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                    IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number     IN            NUMBER
  , p_task_id                   IN            NUMBER
  , p_delete_future_recurrences IN            VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  PROCEDURE export_file(
    p_path          IN            VARCHAR2
  , p_file_name     IN            VARCHAR2
  , p_task_table    IN            jtf_tasks_pub.task_table_type
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  PROCEDURE query_task(
    p_object_version_number IN            NUMBER
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE
  , p_description           IN            jtf_tasks_v.description%TYPE
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE
  , p_ref_object_id         IN            NUMBER
  , p_ref_object_type_code  IN            VARCHAR2
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE
  , p_sort_data             IN            jtf_tasks_pub.sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    jtf_tasks_pub.task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_location_id           IN            NUMBER
  );

  PROCEDURE query_task(
    p_object_version_number IN            NUMBER
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE
  , p_description           IN            jtf_tasks_v.description%TYPE
  , p_task_type_id          IN            jtf_tasks_v.task_type_id%TYPE
  , p_task_status_id        IN            jtf_tasks_v.task_status_id%TYPE
  , p_task_priority_id      IN            jtf_tasks_v.task_priority_id%TYPE
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE
  , p_assigned_by_id        IN            jtf_tasks_v.assigned_by_id%TYPE
  , p_address_id            IN            jtf_tasks_v.address_id%TYPE
  , p_owner_territory_id    IN            jtf_tasks_v.owner_territory_id%TYPE DEFAULT NULL
  , p_customer_id           IN            jtf_tasks_v.customer_id%TYPE DEFAULT NULL
  , p_cust_account_id       IN            jtf_tasks_v.cust_account_id%TYPE DEFAULT NULL
  , p_planned_start_date    IN            jtf_tasks_v.planned_start_date%TYPE
  , p_planned_end_date      IN            jtf_tasks_v.planned_end_date%TYPE
  , p_scheduled_start_date  IN            jtf_tasks_v.scheduled_start_date%TYPE
  , p_scheduled_end_date    IN            jtf_tasks_v.scheduled_end_date%TYPE
  , p_actual_start_date     IN            jtf_tasks_v.actual_start_date%TYPE
  , p_actual_end_date       IN            jtf_tasks_v.actual_end_date%TYPE
  , p_object_type_code      IN            jtf_tasks_v.source_object_type_code%TYPE
  , p_source_object_id      IN            jtf_tasks_v.source_object_id%TYPE
  , p_percentage_complete   IN            jtf_tasks_v.percentage_complete%TYPE
  , p_reason_code           IN            jtf_tasks_v.reason_code%TYPE
  , p_private_flag          IN            jtf_tasks_v.private_flag%TYPE
  , p_restrict_closure_flag IN            jtf_tasks_v.restrict_closure_flag%TYPE
  , p_multi_booked_flag     IN            jtf_tasks_v.multi_booked_flag%TYPE
  , p_milestone_flag        IN            jtf_tasks_v.milestone_flag%TYPE
  , p_holiday_flag          IN            jtf_tasks_v.holiday_flag%TYPE
  , p_workflow_process_id   IN            jtf_tasks_v.workflow_process_id%TYPE
  , p_notification_flag     IN            jtf_tasks_v.notification_flag%TYPE
  , p_parent_task_id        IN            jtf_tasks_v.parent_task_id%TYPE
  , p_alarm_on              IN            jtf_tasks_v.alarm_on%TYPE
  , p_alarm_count           IN            jtf_tasks_v.alarm_count%TYPE
  , p_alarm_fired_count     IN            jtf_tasks_v.alarm_fired_count%TYPE
  , p_ref_object_id         IN            NUMBER
  , p_ref_object_type_code  IN            VARCHAR2
  , p_task_name             IN            jtf_tasks_v.task_name%TYPE
  , p_sort_data             IN            jtf_tasks_pub.sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    jtf_tasks_pub.task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  PROCEDURE query_next_task(
    p_object_version_number IN            NUMBER
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE
  ,   -- current task id
    p_query_type            IN            VARCHAR2 DEFAULT 'Dependency'
  ,   -- values Dependency, Owner, assigned
    p_date_type             IN            VARCHAR2 DEFAULT NULL
  , p_date_start_or_end     IN            VARCHAR2 DEFAULT NULL
  , p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
  , p_owner_type_code       IN            jtf_tasks_v.owner_type_code%TYPE DEFAULT NULL
  , p_assigned_by           IN            jtf_tasks_v.assigned_by_id%TYPE DEFAULT NULL
  , p_sort_data             IN            jtf_tasks_pub.sort_data
  , p_start_pointer         IN            NUMBER
  , p_rec_wanted            IN            NUMBER
  , p_show_all              IN            VARCHAR2 DEFAULT 'Y'
  , p_query_or_next_code    IN            VARCHAR2 DEFAULT 'Q'
  , x_task_table            OUT NOCOPY    jtf_tasks_pub.task_table_type
  , x_total_retrieved       OUT NOCOPY    NUMBER
  , x_total_returned        OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

  -- Created for Enh 2797666
  TYPE sub_task_rec IS RECORD(
    task_id              jtf_tasks_b.task_id%TYPE                := fnd_api.g_miss_num
  , task_type_id         jtf_tasks_b.task_type_id%TYPE           := fnd_api.g_miss_num
  , task_status_id       jtf_tasks_b.task_status_id%TYPE         := fnd_api.g_miss_num
  , task_priority_id     jtf_tasks_b.task_priority_id%TYPE       := fnd_api.g_miss_num
  , planned_start_date   jtf_tasks_b.planned_start_date%TYPE     := fnd_api.g_miss_date
  , planned_end_date     jtf_tasks_b.planned_end_date%TYPE       := fnd_api.g_miss_date
  , scheduled_start_date jtf_tasks_b.scheduled_start_date%TYPE   := fnd_api.g_miss_date
  , scheduled_end_date   jtf_tasks_b.scheduled_end_date%TYPE     := fnd_api.g_miss_date
  , actual_start_date    jtf_tasks_b.actual_start_date%TYPE      := fnd_api.g_miss_date
  , actual_end_date      jtf_tasks_b.actual_end_date%TYPE        := fnd_api.g_miss_date
  , p_enable_workflow    VARCHAR2(1)
  , abort_workflow       VARCHAR2(1)
  );
END;   -- Package spec

/
