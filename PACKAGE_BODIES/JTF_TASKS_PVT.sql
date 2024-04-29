--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_PVT" AS
  /* $Header: jtfvtktb.pls 120.18.12010000.3 2009/06/15 08:23:08 anangupt ship $ */
  g_pkg_name       CONSTANT VARCHAR2(30)                                   := 'JTF_TASKS_PVT';
  g_entity         CONSTANT jtf_tasks_b.entity%TYPE                        := 'TASK';
  g_free_busy_type CONSTANT jtf_task_all_assignments.free_busy_type%TYPE   := 'FREE';
  v_select                  VARCHAR2(6000);
  -- table for query_task
  v_tbl                     jtf_tasks_pub.task_table_type;
  -- table for query_task
  v_n_tbl                   jtf_tasks_pub.task_table_type;

  -- original version to call the new version which has a workflow enhancement
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pvt2;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_id                    => x_task_id
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_template_id                => p_template_id
    , p_template_group_id          => p_template_group_id
    , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
    , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
    , p_entity                     => g_entity
    , p_free_busy_type             => NULL
    , p_task_confirmation_status   => 'N'
    , p_task_confirmation_counter  => NULL
    , p_task_split_flag            => NULL
    , p_reference_flag             => NULL
    , p_child_position             => NULL
    , p_child_sequence_num         => NULL
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pvt2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pvt2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- new version which has a workflow enhancement
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pvt3;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    ,
      -- passing FALSE so we can commit after processing the table parameters
      p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_id                    => x_task_id
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_template_id                => p_template_id
    , p_template_group_id          => p_template_group_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_entity                     => g_entity
    , p_free_busy_type             => NULL
    , p_task_confirmation_status   => 'N'
    , p_task_confirmation_counter  => NULL
    , p_task_split_flag            => NULL
    , p_reference_flag             => NULL
    , p_child_position             => NULL
    , p_child_sequence_num         => NULL
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pvt3;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pvt3;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- overloaded version to add p_entity and p_free_busy_type..
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
  , p_planned_start_date      IN            DATE DEFAULT NULL
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pvt1;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_id                    => x_task_id
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_template_id                => p_template_id
    , p_template_group_id          => p_template_group_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_entity                     => p_entity
    , p_free_busy_type             => p_free_busy_type
    , p_task_confirmation_status   => 'N'
    , p_task_confirmation_counter  => NULL
    , p_task_split_flag            => NULL
    , p_reference_flag             => NULL
    , p_child_position             => NULL
    , p_child_sequence_num         => NULL
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pvt1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pvt1;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Overloaded version for Simplex Changes..
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pvt4;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    ,   ---- hz_party_sites
      p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_id                    => x_task_id
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_template_id                => p_template_id
    , p_template_group_id          => p_template_group_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_entity                     => p_entity
    , p_free_busy_type             => p_free_busy_type
    , p_task_confirmation_status   => p_task_confirmation_status
    , p_task_confirmation_counter  => p_task_confirmation_counter
    , p_task_split_flag            => p_task_split_flag
    , p_reference_flag             => p_reference_flag
    , p_child_position             => p_child_position
    , p_child_sequence_num         => p_child_sequence_num
    , p_location_id                => NULL
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pvt4;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pvt4;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Overloaded version for Location Id..
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
  , p_planned_start_date        IN            DATE DEFAULT NULL
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
  ) IS
    l_api_version     CONSTANT NUMBER                                           := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                                     := 'CREATE_TASK';

    l_return_status            VARCHAR2(1)                                      := fnd_api.g_ret_sts_success;
    l_rowid                    ROWID;
    l_task_number              jtf_tasks_b.task_number%TYPE;
    l_owner_id                 jtf_tasks_b.owner_id%TYPE                        := p_owner_id;
    l_owner_type_code          jtf_tasks_b.owner_type_code%TYPE                 := p_owner_type_code;
    l_task_type_id             jtf_tasks_b.task_type_id%TYPE                    := p_task_type_id;
    l_task_status_id           jtf_tasks_b.task_status_id%TYPE                  := p_task_status_id;
    l_task_priority_id         jtf_tasks_b.task_priority_id%TYPE                := p_task_priority_id;
    l_source_object_id         jtf_tasks_b.source_object_id%TYPE                := p_source_object_id;
    ---
    --- to fix bug #2224949
    ---
    l_source_object_name       jtf_tasks_b.source_object_name%TYPE              := jtf_task_utl.check_truncation(p_object_name => p_source_object_name);
    l_source_object_type_code  jtf_tasks_b.source_object_type_code%TYPE         := p_source_object_type_code;
    l_duration                 jtf_tasks_b.DURATION%TYPE                        := p_duration;
    l_duration_uom             jtf_tasks_b.duration_uom%TYPE                    := p_duration_uom;
    l_planned_effort           jtf_tasks_b.planned_effort%TYPE                  := p_planned_effort;
    l_planned_effort_uom       jtf_tasks_b.planned_effort_uom%TYPE              := p_planned_effort_uom;
    l_actual_effort            jtf_tasks_b.actual_effort%TYPE                   := p_actual_effort;
    l_actual_effort_uom        jtf_tasks_b.actual_effort_uom%TYPE               := p_actual_effort_uom;
    l_percentage_complete      jtf_tasks_b.percentage_complete%TYPE             := p_percentage_complete;
    l_reason_code              jtf_tasks_b.reason_code%TYPE                     := p_reason_code;
    l_date_selected            jtf_tasks_b.date_selected%TYPE;
    l_calendar_start_date      jtf_tasks_b.calendar_start_date%TYPE;
    l_calendar_end_date        jtf_tasks_b.calendar_end_date%TYPE;
    l_planned_start_date       jtf_tasks_b.planned_start_date%TYPE              := p_planned_start_date;
    l_planned_end_date         jtf_tasks_b.planned_end_date%TYPE                := p_planned_end_date;
    l_scheduled_start_date     jtf_tasks_b.scheduled_start_date%TYPE            := p_scheduled_start_date;
    l_scheduled_end_date       jtf_tasks_b.scheduled_end_date%TYPE              := p_scheduled_end_date;
    l_actual_start_date        jtf_tasks_b.actual_start_date%TYPE               := p_actual_start_date;
    l_actual_end_date          jtf_tasks_b.actual_end_date%TYPE                 := p_actual_end_date;
    l_task_assignment_id       jtf_task_assignments.task_assignment_id%TYPE;
    l_category_id              jtf_task_assignments.category_id%TYPE            := p_category_id;
    l_owner_status_id          jtf_task_assignments.assignment_status_id%TYPE;
    l_show_on_calendar         jtf_task_assignments.show_on_calendar%TYPE;
    l_task_reference_id        jtf_task_references_b.task_reference_id%TYPE;
    l_enable_workflow          VARCHAR2(1)                                      := p_enable_workflow;
    l_abort_workflow           VARCHAR2(1)                                      := p_abort_workflow;
    x_event_return_status      VARCHAR2(100);
    -- Booking enhancement
    l_entity                   jtf_tasks_b.entity%TYPE                          := p_entity;
    l_free_busy_type           jtf_task_all_assignments.free_busy_type%TYPE     := p_free_busy_type;
    l_open_flag                VARCHAR2(1);
    l_task_confirmation_status jtf_tasks_b.task_confirmation_status%TYPE        := p_task_confirmation_status;
    l_res_type                 jtf_task_rsc_reqs.resource_type_code%TYPE;
    l_req_units                jtf_task_rsc_reqs.required_units%TYPE;
    l_enabled_flag             jtf_task_rsc_reqs.enabled_flag%TYPE;
    l_resource_req_id          jtf_task_rsc_reqs.resource_req_id%TYPE;

    CURSOR c_type_reqs IS
      SELECT resource_type_code, required_units, enabled_flag
        FROM jtf_task_rsc_reqs
       WHERE task_type_id = l_task_type_id;

    CURSOR c_jtf_tasks IS
      SELECT 'Y'
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    l_task_id_duplicate        VARCHAR2(1);
    l_task_rec_type            jtf_tasks_pvt.task_rec_type;
  BEGIN
    SAVEPOINT create_task_pvt;

    x_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_task_name IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_NAME');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_task_split_flag IS NOT NULL THEN
      IF NOT p_task_split_flag IN('M', 'D') THEN
        fnd_message.set_name('JTF', 'JTF_TASK_CONSTRUCT_ID');
        fnd_message.set_token('%P_SHITF_CONSTRUCT_ID', 'task split flag');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF NOT p_task_confirmation_status IN('N', 'R', 'C') THEN
      fnd_message.set_name('JTF', 'JTF_TASK_CONSTRUCT_ID');
      fnd_message.set_token('P_SHITF_CONSTRUCT_ID', 'task confirmation status');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_enable_workflow IS NULL OR p_enable_workflow = fnd_api.g_miss_char THEN
      l_enable_workflow  := g_enable_workflow;
    END IF;

    IF p_abort_workflow IS NULL OR p_abort_workflow = fnd_api.g_miss_char THEN
      l_abort_workflow  := g_abort_workflow;
    END IF;

    IF p_task_id IS NOT NULL THEN
      IF p_task_id > jtf_task_utl_ext.get_last_number('JTF_TASKS_S') AND p_task_id < 1e+12 THEN
        fnd_message.set_name('JTF', 'JTF_TASK_OUT_OF_RANGE');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_jtf_tasks;
      FETCH c_jtf_tasks INTO l_task_id_duplicate;
      CLOSE c_jtf_tasks;

      IF l_task_id_duplicate = 'Y' THEN
        fnd_message.set_name('JTF', 'JTF_TASK_DUPLICATE_TASK_ID');
        fnd_message.set_token('P_TASK_ID', p_task_id);
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      SELECT jtf_task_number_s.NEXTVAL
        INTO l_task_number
        FROM DUAL;

      x_task_id := p_task_id;
    ELSE
      SELECT jtf_tasks_s.NEXTVAL
        INTO x_task_id
        FROM DUAL;

      SELECT jtf_task_number_s.NEXTVAL
        INTO l_task_number
        FROM DUAL;
    END IF;

    -- ------------------------------------------------------------------------
    -- Call jtf_task_utl procedure to set calendar_start_date and
    -- calendar_end_date
    -- ------------------------------------------------------------------------
    jtf_task_utl_ext.set_calendar_dates(
      p_show_on_calendar           => p_show_on_calendar
    , p_date_selected              => p_date_selected
    , p_planned_start_date         => l_planned_start_date
    , p_planned_end_date           => l_planned_end_date
    , p_scheduled_start_date       => l_scheduled_start_date
    , p_scheduled_end_date         => l_scheduled_end_date
    , p_actual_start_date          => l_actual_start_date
    , p_actual_end_date            => l_actual_end_date
    , x_show_on_calendar           => l_show_on_calendar
    , x_date_selected              => l_date_selected
    , x_calendar_start_date        => l_calendar_start_date
    , x_calendar_end_date          => l_calendar_end_date
    , x_return_status              => x_return_status
    , p_task_status_id             => l_task_status_id-- Enhancement 2683868: new parameter
    , p_creation_date              => SYSDATE   -- Enhancement 2683868: new parameter
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- ------------------------------------------------------------------------
    -- If date_selected was not present then set the appropriate dates
    -- depending on date_selected returned from set_calendar_dates, to fix
    -- bug #1889371
    -- ------------------------------------------------------------------------
    IF p_date_selected IS NULL OR p_date_selected = fnd_api.g_miss_char THEN
      IF l_date_selected = 'P' THEN
        l_planned_start_date  := l_calendar_start_date;
        l_planned_end_date    := l_calendar_end_date;
      ELSIF l_date_selected = 'S' THEN
        l_scheduled_start_date  := l_calendar_start_date;
        l_scheduled_end_date    := l_calendar_end_date;
      ELSIF l_date_selected = 'A' THEN
        l_actual_start_date  := l_calendar_start_date;
        l_actual_end_date    := l_calendar_end_date;
      END IF;
    END IF;

    -- ------------------------------------------------------------------------
    -- If type is Appointment then set scheduled dates to the value of the
    -- planned dates, to fix bug #1889178
    -- ------------------------------------------------------------------------
    IF p_source_object_type_code = 'APPOINTMENT' THEN
      l_scheduled_start_date  := l_planned_start_date;
      l_scheduled_end_date    := l_planned_end_date;
    END IF;

    -- ------------------------------------------------------------------------
    -- If source is Task or Appointment then set source_id to task_id and
    -- source_name to task_number
    -- ------------------------------------------------------------------------
    IF    p_source_object_type_code IN('TASK', 'APPOINTMENT', fnd_api.g_miss_char)
       OR p_source_object_type_code IS NULL THEN
      l_source_object_id    := x_task_id;
      l_source_object_name  := l_task_number;

      IF p_source_object_type_code IS NOT NULL AND p_source_object_type_code <> fnd_api.g_miss_char THEN
        l_source_object_type_code  := p_source_object_type_code;
      ELSE
        l_source_object_type_code  := 'TASK';
      END IF;
    ELSE
      l_source_object_type_code  := p_source_object_type_code;
      l_source_object_id         := p_source_object_id;
      --- to fix bug #2224949 and 2384479
      -- Bug 2602732
      l_source_object_name       := jtf_task_utl.check_truncation(jtf_task_utl.get_owner(l_source_object_type_code, l_source_object_id));
    --Chanaged For Bug # 2573617
    END IF;

    -- Enhancement for booking--
    IF (l_task_type_id = 22) THEN
      l_entity  := 'ESCALATION';
    ELSIF(l_source_object_type_code = 'APPOINTMENT') THEN
      l_entity  := 'APPOINTMENT';
    END IF;

    --- Validate Priority... Bug 3342819
    IF (l_task_priority_id = fnd_api.g_miss_num) OR(l_task_priority_id IS NULL) THEN
      l_task_priority_id  := 8;
    END IF;

    l_open_flag                                                := jtf_task_utl_ext.get_open_flag(l_task_status_id);
    jtf_tasks_pub.p_task_user_hooks.task_id                    := x_task_id;
    jtf_tasks_pub.p_task_user_hooks.task_number                := l_task_number;
    jtf_tasks_pub.p_task_user_hooks.task_name                  := p_task_name;
    jtf_tasks_pub.p_task_user_hooks.task_type_id               := l_task_type_id;
    jtf_tasks_pub.p_task_user_hooks.description                := p_description;
    jtf_tasks_pub.p_task_user_hooks.task_status_id             := l_task_status_id;
    jtf_tasks_pub.p_task_user_hooks.task_priority_id           := l_task_priority_id;
    jtf_tasks_pub.p_task_user_hooks.owner_type_code            := l_owner_type_code;
    jtf_tasks_pub.p_task_user_hooks.owner_id                   := l_owner_id;
    jtf_tasks_pub.p_task_user_hooks.owner_territory_id         := p_owner_territory_id;
    jtf_tasks_pub.p_task_user_hooks.assigned_by_id             := p_assigned_by_id;
    jtf_tasks_pub.p_task_user_hooks.customer_id                := p_customer_id;
    jtf_tasks_pub.p_task_user_hooks.cust_account_id            := p_cust_account_id;
    jtf_tasks_pub.p_task_user_hooks.address_id                 := p_address_id;
    jtf_tasks_pub.p_task_user_hooks.planned_start_date         := l_planned_start_date;
    jtf_tasks_pub.p_task_user_hooks.planned_end_date           := l_planned_end_date;
    jtf_tasks_pub.p_task_user_hooks.scheduled_start_date       := l_scheduled_start_date;
    jtf_tasks_pub.p_task_user_hooks.scheduled_end_date         := l_scheduled_end_date;
    jtf_tasks_pub.p_task_user_hooks.actual_start_date          := l_actual_start_date;
    jtf_tasks_pub.p_task_user_hooks.actual_end_date            := l_actual_end_date;
    jtf_tasks_pub.p_task_user_hooks.timezone_id                := p_timezone_id;
    jtf_tasks_pub.p_task_user_hooks.source_object_type_code    := l_source_object_type_code;
    jtf_tasks_pub.p_task_user_hooks.source_object_id           := l_source_object_id;
    jtf_tasks_pub.p_task_user_hooks.source_object_name         := l_source_object_name;
    jtf_tasks_pub.p_task_user_hooks.DURATION                   := l_duration;
    jtf_tasks_pub.p_task_user_hooks.duration_uom               := l_duration_uom;
    jtf_tasks_pub.p_task_user_hooks.planned_effort             := l_planned_effort;
    jtf_tasks_pub.p_task_user_hooks.planned_effort_uom         := l_planned_effort_uom;
    jtf_tasks_pub.p_task_user_hooks.actual_effort              := l_actual_effort;
    jtf_tasks_pub.p_task_user_hooks.actual_effort_uom          := l_actual_effort_uom;
    jtf_tasks_pub.p_task_user_hooks.percentage_complete        := l_percentage_complete;
    jtf_tasks_pub.p_task_user_hooks.reason_code                := l_reason_code;
    jtf_tasks_pub.p_task_user_hooks.private_flag               := p_private_flag;
    jtf_tasks_pub.p_task_user_hooks.publish_flag               := p_publish_flag;
    jtf_tasks_pub.p_task_user_hooks.restrict_closure_flag      := p_restrict_closure_flag;
    jtf_tasks_pub.p_task_user_hooks.multi_booked_flag          := p_multi_booked_flag;
    jtf_tasks_pub.p_task_user_hooks.milestone_flag             := p_milestone_flag;
    jtf_tasks_pub.p_task_user_hooks.holiday_flag               := p_holiday_flag;
    jtf_tasks_pub.p_task_user_hooks.billable_flag              := p_billable_flag;
    jtf_tasks_pub.p_task_user_hooks.bound_mode_code            := p_bound_mode_code;
    jtf_tasks_pub.p_task_user_hooks.soft_bound_flag            := p_soft_bound_flag;
    jtf_tasks_pub.p_task_user_hooks.workflow_process_id        := p_workflow_process_id;
    jtf_tasks_pub.p_task_user_hooks.notification_flag          := p_notification_flag;
    jtf_tasks_pub.p_task_user_hooks.notification_period        := p_notification_period;
    jtf_tasks_pub.p_task_user_hooks.notification_period_uom    := p_notification_period_uom;
    jtf_tasks_pub.p_task_user_hooks.parent_task_id             := p_parent_task_id;
    jtf_tasks_pub.p_task_user_hooks.alarm_start                := p_alarm_start;
    jtf_tasks_pub.p_task_user_hooks.alarm_start_uom            := p_alarm_start_uom;
    jtf_tasks_pub.p_task_user_hooks.alarm_on                   := p_alarm_on;
    jtf_tasks_pub.p_task_user_hooks.alarm_count                := p_alarm_count;
    jtf_tasks_pub.p_task_user_hooks.alarm_interval             := p_alarm_interval;
    jtf_tasks_pub.p_task_user_hooks.alarm_interval_uom         := p_alarm_interval_uom;
    jtf_tasks_pub.p_task_user_hooks.palm_flag                  := p_palm_flag;
    jtf_tasks_pub.p_task_user_hooks.wince_flag                 := p_wince_flag;
    jtf_tasks_pub.p_task_user_hooks.laptop_flag                := p_laptop_flag;
    jtf_tasks_pub.p_task_user_hooks.device1_flag               := p_device1_flag;
    jtf_tasks_pub.p_task_user_hooks.device2_flag               := p_device2_flag;
    jtf_tasks_pub.p_task_user_hooks.device3_flag               := p_device3_flag;
    jtf_tasks_pub.p_task_user_hooks.costs                      := p_costs;
    jtf_tasks_pub.p_task_user_hooks.currency_code              := p_currency_code;
    jtf_tasks_pub.p_task_user_hooks.escalation_level           := p_escalation_level;
    jtf_tasks_pub.p_task_user_hooks.date_selected              := l_date_selected;
    jtf_tasks_pub.p_task_user_hooks.template_id                := p_template_id;
    jtf_tasks_pub.p_task_user_hooks.template_group_id          := p_template_group_id;
    jtf_tasks_pub.p_task_user_hooks.attribute1                 := p_attribute1;
    jtf_tasks_pub.p_task_user_hooks.attribute2                 := p_attribute2;
    jtf_tasks_pub.p_task_user_hooks.attribute3                 := p_attribute3;
    jtf_tasks_pub.p_task_user_hooks.attribute4                 := p_attribute4;
    jtf_tasks_pub.p_task_user_hooks.attribute5                 := p_attribute5;
    jtf_tasks_pub.p_task_user_hooks.attribute6                 := p_attribute6;
    jtf_tasks_pub.p_task_user_hooks.attribute7                 := p_attribute7;
    jtf_tasks_pub.p_task_user_hooks.attribute8                 := p_attribute8;
    jtf_tasks_pub.p_task_user_hooks.attribute9                 := p_attribute9;
    jtf_tasks_pub.p_task_user_hooks.attribute10                := p_attribute10;
    jtf_tasks_pub.p_task_user_hooks.attribute11                := p_attribute11;
    jtf_tasks_pub.p_task_user_hooks.attribute12                := p_attribute12;
    jtf_tasks_pub.p_task_user_hooks.attribute13                := p_attribute13;
    jtf_tasks_pub.p_task_user_hooks.attribute14                := p_attribute14;
    jtf_tasks_pub.p_task_user_hooks.attribute15                := p_attribute15;
    jtf_tasks_pub.p_task_user_hooks.attribute_category         := p_attribute_category;
    jtf_tasks_pub.p_task_user_hooks.entity                     := l_entity;
    jtf_tasks_pub.p_task_user_hooks.task_confirmation_status   := l_task_confirmation_status;
    jtf_tasks_pub.p_task_user_hooks.task_confirmation_counter  := p_task_confirmation_counter;
    jtf_tasks_pub.p_task_user_hooks.task_split_flag            := p_task_split_flag;
    jtf_tasks_pub.p_task_user_hooks.child_position             := p_child_position;
    jtf_tasks_pub.p_task_user_hooks.child_sequence_num         := p_child_sequence_num;
    jtf_tasks_pub.p_task_user_hooks.open_flag                  := l_open_flag;
    jtf_tasks_pub.p_task_user_hooks.location_id                := p_location_id;
    jtf_tasks_pub.p_task_user_hooks.copied_from_task_id        := p_copied_from_task_id;

    jtf_tasks_iuhk.create_task_pre(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    jtf_tasks_pkg.insert_row(
      x_rowid                      => l_rowid
    , x_task_id                    => x_task_id
    , x_source_object_id           => l_source_object_id
    , x_source_object_name         => l_source_object_name
    , x_duration                   => l_duration
    , x_duration_uom               => l_duration_uom
    , x_planned_effort             => l_planned_effort
    , x_planned_effort_uom         => l_planned_effort_uom
    , x_actual_effort              => l_actual_effort
    , x_actual_effort_uom          => l_actual_effort_uom
    , x_percentage_complete        => l_percentage_complete
    , x_reason_code                => l_reason_code
    , x_private_flag               => p_private_flag
    , x_publish_flag               => p_publish_flag
    , x_restrict_closure_flag      => p_restrict_closure_flag
    , x_multi_booked_flag          => p_multi_booked_flag
    , x_milestone_flag             => p_milestone_flag
    , x_holiday_flag               => p_holiday_flag
    , x_billable_flag              => p_billable_flag
    , x_bound_mode_code            => p_bound_mode_code
    , x_soft_bound_flag            => p_soft_bound_flag
    , x_workflow_process_id        => p_workflow_process_id
    , x_costs                      => p_costs
    , x_currency_code              => p_currency_code
    , x_notification_flag          => p_notification_flag
    , x_notification_period        => p_notification_period
    , x_notification_period_uom    => p_notification_period_uom
    , x_parent_task_id             => p_parent_task_id
    , x_recurrence_rule_id         => NULL
    , x_alarm_start                => p_alarm_start
    , x_alarm_start_uom            => p_alarm_start_uom
    , x_alarm_on                   => p_alarm_on
    , x_alarm_count                => p_alarm_count
    , x_alarm_fired_count          => NULL
    , x_alarm_interval             => p_alarm_interval
    , x_alarm_interval_uom         => p_alarm_interval_uom
    , x_deleted_flag               => 'N'
    , x_palm_flag                  => p_palm_flag
    , x_wince_flag                 => p_wince_flag
    , x_laptop_flag                => p_laptop_flag
    , x_device1_flag               => p_device1_flag
    , x_device2_flag               => p_device2_flag
    , x_device3_flag               => p_device3_flag
    , x_attribute1                 => p_attribute1
    , x_attribute2                 => p_attribute2
    , x_attribute3                 => p_attribute3
    , x_attribute4                 => p_attribute4
    , x_attribute5                 => p_attribute5
    , x_attribute6                 => p_attribute6
    , x_attribute7                 => p_attribute7
    , x_attribute8                 => p_attribute8
    , x_attribute9                 => p_attribute9
    , x_attribute10                => p_attribute10
    , x_attribute11                => p_attribute11
    , x_attribute12                => p_attribute12
    , x_attribute13                => p_attribute13
    , x_attribute14                => p_attribute14
    , x_attribute15                => p_attribute15
    , x_attribute_category         => p_attribute_category
    , x_task_number                => l_task_number
    , x_task_type_id               => l_task_type_id
    , x_task_status_id             => l_task_status_id
    , x_task_priority_id           => l_task_priority_id
    , x_owner_id                   => l_owner_id
    , x_owner_type_code            => l_owner_type_code
    , x_owner_territory_id         => p_owner_territory_id
    , x_assigned_by_id             => p_assigned_by_id
    , x_cust_account_id            => p_cust_account_id
    , x_customer_id                => p_customer_id
    , x_address_id                 => p_address_id
    , x_planned_start_date         => l_planned_start_date
    , x_planned_end_date           => l_planned_end_date
    , x_scheduled_start_date       => l_scheduled_start_date
    , x_scheduled_end_date         => l_scheduled_end_date
    , x_actual_start_date          => l_actual_start_date
    , x_actual_end_date            => l_actual_end_date
    , x_source_object_type_code    => l_source_object_type_code
    , x_timezone_id                => p_timezone_id
    , x_task_name                  => p_task_name
    , x_description                => p_description
    , x_creation_date              => SYSDATE
    , x_created_by                 => jtf_task_utl.created_by
    , x_last_update_date           => SYSDATE
    , x_last_updated_by            => jtf_task_utl.updated_by
    , x_last_update_login          => jtf_task_utl.login_id
    , x_escalation_level           => p_escalation_level
    , x_calendar_start_date        => l_calendar_start_date
    , x_calendar_end_date          => l_calendar_end_date
    , x_date_selected              => l_date_selected
    , x_template_id                => p_template_id
    , x_template_group_id          => p_template_group_id
    , x_open_flag                  => jtf_task_utl_ext.get_open_flag(l_task_status_id)    -- Enhancement# 2666995
    , x_entity                     => l_entity                                            -- enh# 3535354
    , x_task_confirmation_status   => l_task_confirmation_status
    , x_task_confirmation_counter  => p_task_confirmation_counter
    , x_task_split_flag            => p_task_split_flag
    , x_child_position             => p_child_position
    , x_child_sequence_num         => p_child_sequence_num
    , x_location_id                => p_location_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- ------------------------------------------------------------------------
    -- Create task assignment for Owner
    -- ------------------------------------------------------------------------

    -- ------------------------------------------------------------------------
    -- Set owner_status_id from profile if not supplied
    -- ------------------------------------------------------------------------
    IF p_owner_status_id IS NULL OR p_owner_status_id = fnd_api.g_miss_num THEN
      -- Added NVL on 04/08/2006 for bug# 5408967
      l_owner_status_id  := NVL(fnd_profile.VALUE(NAME => 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'), 3);
    ELSE
      l_owner_status_id  := p_owner_status_id;
    END IF;

    jtf_task_assignments_pvt.create_task_assignment(
      p_api_version                => l_api_version
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_task_assignment_id         => l_task_assignment_id
    , p_task_id                    => x_task_id
    , p_resource_type_code         => l_owner_type_code
    , p_resource_id                => l_owner_id
    , p_actual_effort              => l_actual_effort
    , p_actual_effort_uom          => l_actual_effort_uom
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_resource_territory_id      => p_owner_territory_id
    , p_assignment_status_id       => l_owner_status_id
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_assignment_id         => l_task_assignment_id
    , p_assignee_role              => 'OWNER'
    , p_show_on_calendar           => l_show_on_calendar
    , p_category_id                => l_category_id
    , p_enable_workflow            => l_enable_workflow
    , p_abort_workflow             => l_abort_workflow
    , p_add_option                 => jtf_task_repeat_appt_pvt.g_one
    , p_free_busy_type             => l_free_busy_type
    );

    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ((p_reference_flag = 'Y') OR(p_reference_flag IS NULL)) THEN
      -- ------------------------------------------------------------------------
      -- Create reference to source document
      -- ------------------------------------------------------------------------
      IF     l_source_object_type_code IS NOT NULL
         AND l_source_object_type_code <> fnd_api.g_miss_char
         AND l_source_object_type_code NOT IN('TASK', 'APPOINTMENT', 'EXTERNAL APPOINTMENT') THEN
        -- 2102281  -- If condition added to invoke jtf_task_utl.create_party_reference only for type 'PARTY'
        IF l_source_object_type_code IN('PARTY') THEN
          jtf_task_utl.create_party_reference(
            p_reference_from             => 'TASK'
          , p_task_id                    => x_task_id
          , p_party_id                   => l_source_object_id
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , x_return_status              => x_return_status
          );
        ELSE
          jtf_task_utl.g_show_error_for_dup_reference  := FALSE;
          jtf_task_references_pvt.create_references(
            p_api_version                => l_api_version
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , p_task_id                    => x_task_id
          , p_object_type_code           => l_source_object_type_code
          , p_object_name                => l_source_object_name
          , p_object_id                  => l_source_object_id
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , x_task_reference_id          => l_task_reference_id
          );
        END IF;
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- ------------------------------------------------------------------------
      -- Create reference to customer, fix for enh #1845501
      -- ------------------------------------------------------------------------
      jtf_task_utl.create_party_reference(
        p_reference_from             => 'TASK'
      , p_task_id                    => x_task_id
      , p_party_id                   => p_customer_id
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;   -- of if condition on p_reference_flag

    jtf_tasks_iuhk.create_task_post(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --BES enh 2391065
    IF (l_entity = 'TASK') THEN
      l_task_rec_type.task_id                  := x_task_id;
      l_task_rec_type.enable_workflow          := l_enable_workflow;
      l_task_rec_type.abort_workflow           := l_abort_workflow;
      l_task_rec_type.source_object_type_code  := p_source_object_type_code;
      l_task_rec_type.source_object_id         := l_source_object_id;
      jtf_task_wf_events_pvt.publish_create_task(
        p_task_rec      => l_task_rec_type
      , x_return_status => x_event_return_status
      );

      IF (x_event_return_status = 'WARNING') THEN
        fnd_message.set_name('JTF', 'JTF_TASK_EVENT_WARNING');
        fnd_message.set_token('P_TASK_ID', x_task_id);
        fnd_msg_pub.ADD;
      ELSIF(x_event_return_status = 'ERROR') THEN
        fnd_message.set_name('JTF', 'JTF_TASK_EVENT_ERROR');
        fnd_message.set_token('P_TASK_ID', x_task_id);
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --BES enh 2391065

    --Create Task Resource Requirements
    OPEN c_type_reqs;

    LOOP
      FETCH c_type_reqs INTO l_res_type, l_req_units, l_enabled_flag;
      EXIT WHEN c_type_reqs%NOTFOUND;
      jtf_task_resources_pub.create_task_rsrc_req(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => x_task_id
      , p_task_template_id           => NULL
      , p_resource_type_code         => l_res_type
      , p_required_units             => l_req_units
      , p_enabled_flag               => l_enabled_flag
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_resource_req_id            => l_resource_req_id
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;

    CLOSE c_type_reqs;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pvt;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pvt;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -----------------
  -----------------
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
  ) IS
  BEGIN
    SAVEPOINT update_task_pvt1;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    update_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    ,   -- FALSE
      p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
    , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
    , p_change_mode                => jtf_task_repeat_appt_pvt.g_one
    , p_free_busy_type             => jtf_task_utl.g_miss_char
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt1;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

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
  , p_enable_workflow         IN            VARCHAR2
  , p_abort_workflow          IN            VARCHAR2
  ) IS
  BEGIN
    SAVEPOINT update_task_pvt2;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    update_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    ,   -- FALSE
      p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_change_mode                => jtf_task_repeat_appt_pvt.g_one
    , p_free_busy_type             => jtf_task_utl.g_miss_char
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- New version which has a workflow enhancement (p_enable_workflow, p_abort_workflow)
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
  ) IS
  BEGIN
    SAVEPOINT update_task_pvt3;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    update_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    ,   -- FALSE
      p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_change_mode                => p_change_mode
    , p_free_busy_type             => jtf_task_utl.g_miss_char
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt3;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt3;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- New version which has a workflow enhancement (p_enable_workflow, p_abort_workflow)
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
  ) IS
  BEGIN
    SAVEPOINT update_task_pvt4;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    update_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    ,   -- FALSE
      p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_change_mode                => p_change_mode
    , p_free_busy_type             => p_free_busy_type
    ,   --Bug# 3606783.
      p_task_confirmation_status   => jtf_task_utl.g_miss_char
    , p_task_confirmation_counter  => jtf_task_utl.g_miss_number
    , p_task_split_flag            => jtf_task_utl.g_miss_char
    , p_child_position             => jtf_task_utl.g_miss_char
    , p_child_sequence_num         => jtf_task_utl.g_miss_number
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt4;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt4;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Simplex Changes..
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
  ) IS
  BEGIN
    SAVEPOINT update_task_pvt5;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    update_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    ,   ---- hz_party_sites
      p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_source_object_type_code    => p_source_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , p_duration                   => p_duration
    , p_duration_uom               => p_duration_uom
    , p_planned_effort             => p_planned_effort
    , p_planned_effort_uom         => p_planned_effort_uom
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_publish_flag               => p_publish_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_billable_flag              => p_billable_flag
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => p_attribute1
    , p_attribute2                 => p_attribute2
    , p_attribute3                 => p_attribute3
    , p_attribute4                 => p_attribute4
    , p_attribute5                 => p_attribute5
    , p_attribute6                 => p_attribute6
    , p_attribute7                 => p_attribute7
    , p_attribute8                 => p_attribute8
    , p_attribute9                 => p_attribute9
    , p_attribute10                => p_attribute10
    , p_attribute11                => p_attribute11
    , p_attribute12                => p_attribute12
    , p_attribute13                => p_attribute13
    , p_attribute14                => p_attribute14
    , p_attribute15                => p_attribute15
    , p_attribute_category         => p_attribute_category
    , p_date_selected              => p_date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_change_mode                => p_change_mode
    , p_free_busy_type             => p_free_busy_type
    , p_task_confirmation_status   => p_task_confirmation_status
    , p_task_confirmation_counter  => p_task_confirmation_counter
    , p_task_split_flag            => p_task_split_flag
    , p_child_position             => p_child_position
    , p_child_sequence_num         => p_child_sequence_num
    , p_location_id                => NULL
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt5;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt5;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Location Id..
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
  , p_planned_start_date        IN            DATE DEFAULT fnd_api.g_miss_date
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
  ) IS
    l_task_id                      jtf_tasks_b.task_id%TYPE;
    l_task_number                  jtf_tasks_b.task_number%TYPE;
    l_task_type_id                 jtf_tasks_b.task_type_id%TYPE;
    l_task_status_id               jtf_tasks_b.task_status_id%TYPE;
    l_task_priority_id             jtf_tasks_b.task_priority_id%TYPE;
    l_owner_id                     jtf_tasks_b.owner_id%TYPE;
    l_owner_type_code              jtf_tasks_b.owner_type_code%TYPE;
    l_assigned_by_id               jtf_tasks_b.assigned_by_id%TYPE;
    l_cust_account_id              jtf_tasks_b.cust_account_id%TYPE;
    l_customer_id                  jtf_tasks_b.customer_id%TYPE;
    l_address_id                   jtf_tasks_b.address_id%TYPE;
    l_location_id                  hz_locations.location_id%TYPE;
    l_planned_start_date           jtf_tasks_b.planned_start_date%TYPE;
    l_planned_end_date             jtf_tasks_b.planned_end_date%TYPE;
    l_scheduled_start_date         jtf_tasks_b.scheduled_start_date%TYPE;
    l_scheduled_end_date           jtf_tasks_b.scheduled_end_date%TYPE;
    l_actual_start_date            jtf_tasks_b.actual_start_date%TYPE;
    l_actual_end_date              jtf_tasks_b.actual_end_date%TYPE;
    l_source_object_type_code      jtf_tasks_b.source_object_type_code%TYPE;
    l_timezone_id                  jtf_tasks_b.timezone_id%TYPE;
    l_source_object_id             jtf_tasks_b.source_object_id%TYPE;
    l_source_object_name           jtf_tasks_b.source_object_name%TYPE;
    l_duration                     jtf_tasks_b.DURATION%TYPE;
    l_duration_uom                 jtf_tasks_b.duration_uom%TYPE;
    l_planned_effort               jtf_tasks_b.planned_effort%TYPE;
    l_planned_effort_uom           jtf_tasks_b.planned_effort_uom%TYPE;
    l_actual_effort                jtf_tasks_b.actual_effort%TYPE;
    l_actual_effort_uom            jtf_tasks_b.actual_effort_uom%TYPE;
    l_percentage_complete          jtf_tasks_b.percentage_complete%TYPE;
    l_reason_code                  jtf_tasks_b.reason_code%TYPE;
    l_private_flag                 jtf_tasks_b.private_flag%TYPE;
    l_publish_flag                 jtf_tasks_b.publish_flag%TYPE;
    l_restrict_closure_flag        jtf_tasks_b.restrict_closure_flag%TYPE;
    l_multi_booked_flag            jtf_tasks_b.multi_booked_flag%TYPE;
    l_milestone_flag               jtf_tasks_b.milestone_flag%TYPE;
    l_holiday_flag                 jtf_tasks_b.holiday_flag%TYPE;
    l_billable_flag                jtf_tasks_b.billable_flag%TYPE;
    l_bound_mode_code              jtf_tasks_b.bound_mode_code%TYPE;
    l_soft_bound_flag              jtf_tasks_b.soft_bound_flag%TYPE;
    l_workflow_process_id          jtf_tasks_b.workflow_process_id%TYPE;
    l_notification_flag            jtf_tasks_b.notification_flag%TYPE;
    l_notification_period          jtf_tasks_b.notification_period%TYPE;
    l_notification_period_uom      jtf_tasks_b.notification_period_uom%TYPE;
    l_parent_task_id               jtf_tasks_b.parent_task_id%TYPE;
    l_alarm_start                  jtf_tasks_b.alarm_start%TYPE;
    l_alarm_start_uom              jtf_tasks_b.alarm_start_uom%TYPE;
    l_alarm_on                     jtf_tasks_b.alarm_on%TYPE;
    l_alarm_count                  jtf_tasks_b.alarm_count%TYPE;
    l_alarm_fired_count            jtf_tasks_b.alarm_fired_count%TYPE;
    l_alarm_interval               jtf_tasks_b.alarm_interval%TYPE;
    l_alarm_interval_uom           jtf_tasks_b.alarm_interval_uom%TYPE;
    l_palm_flag                    jtf_tasks_b.palm_flag%TYPE;
    l_wince_flag                   jtf_tasks_b.wince_flag%TYPE;
    l_laptop_flag                  jtf_tasks_b.laptop_flag%TYPE;
    l_device1_flag                 jtf_tasks_b.device1_flag%TYPE;
    l_device2_flag                 jtf_tasks_b.device2_flag%TYPE;
    l_device3_flag                 jtf_tasks_b.device3_flag%TYPE;
    l_currency_code                jtf_tasks_b.currency_code%TYPE;
    l_costs                        jtf_tasks_b.costs%TYPE;
    l_org_id                       jtf_tasks_b.org_id%TYPE;
    l_task_name                    jtf_tasks_tl.task_name%TYPE;
    l_description                  jtf_tasks_tl.description%TYPE;
    l_escalation_level             jtf_tasks_b.escalation_level%TYPE;
    l_calendar_start_date          jtf_tasks_b.calendar_start_date%TYPE;
    l_calendar_end_date            jtf_tasks_b.calendar_end_date%TYPE;
    l_date_selected                jtf_tasks_b.date_selected%TYPE;
    l_owner_status_id              jtf_task_assignments.assignment_status_id%TYPE;
    l_show_on_calendar             jtf_task_assignments.show_on_calendar%TYPE;
    l_free_busy_type               jtf_task_all_assignments.free_busy_type%TYPE;
    l_task_confirmation_status     jtf_tasks_b.task_confirmation_status%TYPE;
    l_task_confirmation_counter    jtf_tasks_b.task_confirmation_counter%TYPE;
    l_task_split_flag              jtf_tasks_b.task_split_flag%TYPE;
    l_enable_workflow              VARCHAR2(1)                                 := p_enable_workflow;
    l_abort_workflow               VARCHAR2(1)                                  := p_abort_workflow;
    l_child_position               jtf_tasks_b.child_position%TYPE;
    l_child_sequence_num           jtf_tasks_b.child_sequence_num%TYPE;

    CURSOR c_task IS
      SELECT task_number
           , recurrence_rule_id
           , DECODE(p_task_name, fnd_api.g_miss_char, task_name, p_task_name) task_name
           , DECODE(p_task_type_id, fnd_api.g_miss_num, task_type_id, p_task_type_id) task_type_id
           , DECODE(p_description, fnd_api.g_miss_char, description, p_description) description
           , DECODE(p_task_status_id, fnd_api.g_miss_num, task_status_id, p_task_status_id)
                                                                                     task_status_id
           , DECODE(p_task_priority_id, fnd_api.g_miss_num, task_priority_id, p_task_priority_id)
                                                                                   task_priority_id
           , DECODE(p_owner_type_code, fnd_api.g_miss_char, owner_type_code, p_owner_type_code)
                                                                                    owner_type_code
           , DECODE(p_owner_id, fnd_api.g_miss_num, owner_id, p_owner_id) owner_id
           , DECODE(
               p_owner_territory_id
             , fnd_api.g_miss_num, owner_territory_id
             , p_owner_territory_id
             ) owner_territory_id
           , DECODE(p_assigned_by_id, fnd_api.g_miss_num, assigned_by_id, p_assigned_by_id)
                                                                                     assigned_by_id
           , DECODE(p_customer_id, fnd_api.g_miss_num, customer_id, p_customer_id) customer_id
           , DECODE(p_cust_account_id, fnd_api.g_miss_num, cust_account_id, p_cust_account_id)
                                                                                    cust_account_id
           , DECODE(p_address_id, fnd_api.g_miss_num, address_id, p_address_id) address_id
           , DECODE(
               p_planned_start_date
             , fnd_api.g_miss_date, planned_start_date
             , p_planned_start_date
             ) planned_start_date
           , DECODE(p_planned_end_date, fnd_api.g_miss_date, planned_end_date, p_planned_end_date)
                                                                                   planned_end_date
           , DECODE(
               p_scheduled_start_date
             , fnd_api.g_miss_date, scheduled_start_date
             , p_scheduled_start_date
             ) scheduled_start_date
           , DECODE(
               p_scheduled_end_date
             , fnd_api.g_miss_date, scheduled_end_date
             , p_scheduled_end_date
             ) scheduled_end_date
           , DECODE(
               p_actual_start_date
             , fnd_api.g_miss_date, actual_start_date
             , p_actual_start_date
             ) actual_start_date
           , DECODE(p_actual_end_date, fnd_api.g_miss_date, actual_end_date, p_actual_end_date)
                                                                                    actual_end_date
           , DECODE(p_timezone_id, fnd_api.g_miss_num, timezone_id, p_timezone_id) timezone_id
           , DECODE(
               p_workflow_process_id
             , fnd_api.g_miss_num, workflow_process_id
             , p_workflow_process_id
             ) workflow_process_id
           ,
             ---
             --- handle NULL like g_miss_value for these three parameters, to fix bug #2002639
             ---
             DECODE(
               p_source_object_type_code
             , fnd_api.g_miss_char, source_object_type_code
             , NULL, source_object_type_code
             , p_source_object_type_code
             ) source_object_type_code
           , DECODE(
               p_source_object_id
             , fnd_api.g_miss_num, source_object_id
             , NULL, source_object_id
             , p_source_object_id
             ) source_object_id
           ,
             ---
             --- to fix bug #2224949
             ---
             DECODE(
               p_source_object_name
             , fnd_api.g_miss_char, source_object_name
             , NULL, source_object_name
             , jtf_task_utl.check_truncation(p_source_object_name)
             ) source_object_name
           , DECODE(p_duration, fnd_api.g_miss_num, DURATION, p_duration) DURATION
           , DECODE(p_duration_uom, fnd_api.g_miss_char, duration_uom, p_duration_uom) duration_uom
           , DECODE(p_planned_effort, fnd_api.g_miss_num, planned_effort, p_planned_effort)
                                                                                     planned_effort
           , DECODE(
               p_planned_effort_uom
             , fnd_api.g_miss_char, planned_effort_uom
             , p_planned_effort_uom
             ) planned_effort_uom
           , DECODE(p_actual_effort, fnd_api.g_miss_num, actual_effort, p_actual_effort)
                                                                                      actual_effort
           , DECODE(
               p_actual_effort_uom
             , fnd_api.g_miss_char, actual_effort_uom
             , p_actual_effort_uom
             ) actual_effort_uom
           , DECODE(
               p_percentage_complete
             , fnd_api.g_miss_num, percentage_complete
             , p_percentage_complete
             ) percentage_complete
           , DECODE(p_reason_code, fnd_api.g_miss_char, reason_code, p_reason_code) reason_code
           , DECODE(p_private_flag, fnd_api.g_miss_char, private_flag, p_private_flag) private_flag
           , DECODE(p_publish_flag, fnd_api.g_miss_char, publish_flag, p_publish_flag) publish_flag
           , DECODE(
               p_restrict_closure_flag
             , fnd_api.g_miss_char, restrict_closure_flag
             , p_restrict_closure_flag
             ) restrict_closure_flag
           , DECODE(
               p_multi_booked_flag
             , fnd_api.g_miss_char, multi_booked_flag
             , p_multi_booked_flag
             ) multi_booked_flag
           , DECODE(p_milestone_flag, fnd_api.g_miss_char, milestone_flag, p_milestone_flag)
                                                                                     milestone_flag
           , DECODE(p_holiday_flag, fnd_api.g_miss_char, holiday_flag, p_holiday_flag) holiday_flag
           , DECODE(p_billable_flag, fnd_api.g_miss_char, billable_flag, p_billable_flag)
                                                                                      billable_flag
           , DECODE(p_bound_mode_code, fnd_api.g_miss_char, bound_mode_code, p_bound_mode_code)
                                                                                    bound_mode_code
           , DECODE(p_soft_bound_flag, fnd_api.g_miss_char, soft_bound_flag, p_soft_bound_flag)
                                                                                    soft_bound_flag
           , DECODE(
               p_notification_flag
             , fnd_api.g_miss_char, notification_flag
             , p_notification_flag
             ) notification_flag
           , DECODE(
               p_notification_period
             , fnd_api.g_miss_num, notification_period
             , p_notification_period
             ) notification_period
           , DECODE(
               p_notification_period_uom
             , fnd_api.g_miss_char, notification_period_uom
             , p_notification_period_uom
             ) notification_period_uom
           , DECODE(p_parent_task_id, fnd_api.g_miss_num, parent_task_id, p_parent_task_id)
                                                                                     parent_task_id
           , DECODE(p_alarm_start, fnd_api.g_miss_num, alarm_start, p_alarm_start) alarm_start
           , DECODE(p_alarm_start_uom, fnd_api.g_miss_char, alarm_start_uom, p_alarm_start_uom)
                                                                                    alarm_start_uom
           , DECODE(p_alarm_on, fnd_api.g_miss_char, alarm_on, p_alarm_on) alarm_on
           , DECODE(p_alarm_count, fnd_api.g_miss_num, alarm_count, p_alarm_count) alarm_count
           , DECODE(
               p_alarm_fired_count
             , fnd_api.g_miss_num, alarm_fired_count
             , p_alarm_fired_count
             ) alarm_fired_count
           , DECODE(p_alarm_interval, fnd_api.g_miss_num, alarm_interval, p_alarm_interval)
                                                                                     alarm_interval
           , DECODE(
               p_alarm_interval_uom
             , fnd_api.g_miss_char, alarm_interval_uom
             , p_alarm_interval_uom
             ) alarm_interval_uom
           , DECODE(p_palm_flag, fnd_api.g_miss_char, palm_flag, p_palm_flag) palm_flag
           , DECODE(p_wince_flag, fnd_api.g_miss_char, wince_flag, p_wince_flag) wince_flag
           , DECODE(p_laptop_flag, fnd_api.g_miss_char, laptop_flag, p_laptop_flag) laptop_flag
           , DECODE(p_device1_flag, fnd_api.g_miss_char, device1_flag, p_device1_flag) device1_flag
           , DECODE(p_device2_flag, fnd_api.g_miss_char, device2_flag, p_device2_flag) device2_flag
           , DECODE(p_device3_flag, fnd_api.g_miss_char, device3_flag, p_device3_flag) device3_flag
           , DECODE(p_costs, fnd_api.g_miss_num, costs, p_costs) costs
           , DECODE(p_currency_code, fnd_api.g_miss_char, currency_code, p_currency_code)
                                                                                      currency_code
           , DECODE(p_escalation_level, fnd_api.g_miss_char, escalation_level, p_escalation_level)
                                                                                   escalation_level
           , DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) attribute1
           , DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) attribute2
           , DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) attribute3
           , DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) attribute4
           , DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) attribute5
           , DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) attribute6
           , DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) attribute7
           , DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) attribute8
           , DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) attribute9
           , DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) attribute10
           , DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) attribute11
           , DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) attribute12
           , DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) attribute13
           , DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) attribute14
           , DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) attribute15
           , DECODE(
               p_attribute_category
             , fnd_api.g_miss_char, attribute_category
             , p_attribute_category
             ) attribute_category
           , calendar_start_date
           , calendar_end_date
           , DURATION duration_orig
           ,   -- XY Story #140
             DECODE(p_date_selected, fnd_api.g_miss_char, date_selected, p_date_selected)
                                                                                      date_selected
           , creation_date
           , DECODE(
               p_task_confirmation_status
             , jtf_task_utl.g_miss_char, task_confirmation_status
             , p_task_confirmation_status
             ) task_confirmation_status
           , DECODE(
               p_task_confirmation_counter
             , jtf_task_utl.g_miss_number, task_confirmation_counter
             , p_task_confirmation_counter
             ) task_confirmation_counter
           , DECODE(
               p_task_split_flag
             , jtf_task_utl.g_miss_char, task_split_flag
             , p_task_split_flag
             ) task_split_flag
           , DECODE(p_child_position, jtf_task_utl.g_miss_char, child_position, p_child_position)
                                                                                     child_position
           , DECODE(
               p_child_sequence_num
             , jtf_task_utl.g_miss_number, child_sequence_num
             , p_child_sequence_num
             ) child_sequence_num
           , DECODE(p_location_id, fnd_api.g_miss_num, location_id, p_location_id) location_id
        FROM jtf_tasks_vl
       WHERE task_id = p_task_id;

    tasks                          c_task%ROWTYPE;
    x                              NUMBER;

    CURSOR task_ass_u(b_task_id IN NUMBER) IS
      SELECT task_id
           , task_assignment_id
           , object_version_number
           , DECODE(p_owner_id, fnd_api.g_miss_num, resource_id, p_owner_id) resource_id
           , DECODE(p_owner_type_code, fnd_api.g_miss_char, resource_type_code, p_owner_type_code) resource_type_code
           , DECODE(
               p_owner_territory_id
             , fnd_api.g_miss_num, resource_territory_id
             , p_owner_territory_id
             ) resource_territory_id
           , DECODE(l_owner_status_id, fnd_api.g_miss_num, assignment_status_id, l_owner_status_id) assignment_status_id
           , DECODE(l_show_on_calendar, fnd_api.g_miss_char, show_on_calendar, l_show_on_calendar) show_on_calendar
           , DECODE(p_category_id, jtf_task_utl.g_miss_number, category_id, p_category_id) category_id
           , DECODE(p_free_busy_type, jtf_task_utl.g_miss_char, free_busy_type, p_free_busy_type) free_busy_type
        FROM jtf_task_all_assignments
       WHERE assignee_role = 'OWNER' AND task_id = b_task_id;

    task_ass_rec                   task_ass_u%ROWTYPE;

    -- Modified on 19/06/2006 for bug# 5210853
    CURSOR task_ass_orig(b_task_id IN NUMBER) IS
      SELECT   task_id
             , assignment_status_id
             , show_on_calendar
             , category_id
             , resource_id
             , free_busy_type
             , booking_start_date
             , booking_end_date
             , task_assignment_id
             , object_version_number
             , actual_start_date
             , actual_end_date
             , actual_effort
             , actual_effort_uom
             , actual_travel_duration
             , actual_travel_duration_uom
             , assignee_role
          FROM jtf_task_all_assignments
         WHERE task_id = b_task_id
      ORDER BY assignee_role DESC;

    task_ass_orig_rec              task_ass_orig%ROWTYPE;
    -- added for Bug 6031383
    l_booking_start_date           jtf_task_all_assignments.booking_start_date%TYPE;
    l_booking_end_date             jtf_task_all_assignments.booking_end_date%TYPE;

    CURSOR task_cust_orig(b_task_id IN NUMBER) IS
      SELECT customer_id
        FROM jtf_tasks_b
       WHERE task_id = b_task_id;

    l_orig_cust_id                 jtf_tasks_b.customer_id%TYPE;

    -- 2102281
    CURSOR task_source_orig(b_task_id IN NUMBER) IS
      SELECT source_object_id
           , source_object_type_code
           , entity
           , open_flag
        FROM jtf_tasks_b
       WHERE task_id = b_task_id;

    CURSOR c_ref(b_task_id jtf_tasks_b.task_id%TYPE, b_source_id hz_parties.party_id%TYPE) IS
      SELECT task_reference_id
           , object_version_number
        FROM jtf_task_references_b
       WHERE task_id = b_task_id AND object_id = b_source_id;

    l_orig_source_id               jtf_tasks_b.source_object_id%TYPE;
    l_orig_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_entity                       jtf_tasks_b.entity%TYPE;
    l_orig_open_flag               jtf_tasks_b.open_flag%TYPE;
    l_obj_version_number           jtf_task_references_b.object_version_number%TYPE;
    l_task_ref_id                  jtf_task_references_b.task_reference_id%TYPE;

    CURSOR c_del_contacts(c_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT task_contact_id
           , contact_id
           , object_version_number
        FROM jtf_task_contacts
       WHERE task_id = c_task_id;

    l_updated_field_rec            jtf_task_repeat_appt_pvt.updated_field_rec;
    l_assignee_rec                 jtf_task_utl.c_assignee_or_owner%ROWTYPE;
    --BES enh 2391065
    l_task_rec_type_old            jtf_tasks_pvt.task_rec_type;
    l_task_rec_type_new            jtf_tasks_pvt.task_rec_type;
    x_task_upd_rec                 jtf_tasks_pkg.task_upd_rec;   --BES enh
    x_task_audit_id                jtf_task_audits_b.task_audit_id%TYPE;
    x_event_return_status          VARCHAR2(100);
  --BES enh 2391065

    /* moved from pub package*/
    CURSOR c_owner_status_id(b_owner_status_id jtf_task_all_assignments.assignment_status_id%TYPE) IS
      SELECT task_status_id
        FROM jtf_task_statuses_b
       WHERE task_status_id = b_owner_status_id
         --AND assigned_flag = 'Y'
         AND assignment_status_flag = 'Y'   -- Fix bug 2500664
         AND NVL(end_date_active, SYSDATE) >= SYSDATE
         AND NVL(start_date_active, SYSDATE) <= SYSDATE;

  BEGIN
    SAVEPOINT update_task_pvt;
    x_return_status                                            := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF p_task_name IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_NAME');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF p_task_split_flag IS NOT NULL THEN
      IF NOT p_task_split_flag IN('M', 'D', fnd_api.g_miss_char) THEN
        fnd_message.set_name('JTF', 'JTF_TASK_CONSTRUCT_ID');
        fnd_message.set_token('%P_SHITF_CONSTRUCT_ID', 'task split flag');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF NOT p_task_confirmation_status IN('N', 'C', 'R', fnd_api.g_miss_char) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_CONSTRUCT_ID');
      fnd_message.set_token('%P_SHITF_CONSTRUCT_ID', 'task confirmation status');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    OPEN c_task;
    FETCH c_task INTO tasks;
    IF c_task%NOTFOUND THEN
      CLOSE c_task;
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
      fnd_message.set_token('P_TASK_ID', p_task_id);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE c_task;

    -- ------------------------------------------------------------------------
    -- Check that the user has the correct security privilege
    -- ------------------------------------------------------------------------
    jtf_task_utl.check_security_privilege(
      p_task_id       => p_task_id
    , p_session       => 'UPDATE'
    , x_return_status => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_task_id                                                  := p_task_id;
    l_task_name                                                := tasks.task_name;
    l_task_number                                              := tasks.task_number;
    l_task_type_id                                             := tasks.task_type_id;
    l_description                                              := tasks.description;
    l_task_status_id                                           := tasks.task_status_id;
    l_task_priority_id                                         := tasks.task_priority_id;
    l_owner_type_code                                          := tasks.owner_type_code;
    l_owner_id                                                 := tasks.owner_id;
    l_assigned_by_id                                           := tasks.assigned_by_id;
    l_customer_id                                              := tasks.customer_id;
    l_cust_account_id                                          := tasks.cust_account_id;
    l_address_id                                               := tasks.address_id;
    l_planned_start_date                                       := tasks.planned_start_date;
    l_planned_end_date                                         := tasks.planned_end_date;
    l_scheduled_start_date                                     := tasks.scheduled_start_date;
    l_scheduled_end_date                                       := tasks.scheduled_end_date;
    l_actual_start_date                                        := tasks.actual_start_date;
    l_actual_end_date                                          := tasks.actual_end_date;
    l_timezone_id                                              := tasks.timezone_id;
    l_duration                                                 := tasks.DURATION;
    l_duration_uom                                             := tasks.duration_uom;
    l_planned_effort                                           := tasks.planned_effort;
    l_planned_effort_uom                                       := tasks.planned_effort_uom;
    l_actual_effort                                            := tasks.actual_effort;
    l_actual_effort_uom                                        := tasks.actual_effort_uom;
    l_percentage_complete                                      := tasks.percentage_complete;
    l_reason_code                                              := tasks.reason_code;
    l_private_flag                                             := tasks.private_flag;
    l_publish_flag                                             := tasks.publish_flag;
    l_restrict_closure_flag                                    := tasks.restrict_closure_flag;
    l_multi_booked_flag                                        := tasks.multi_booked_flag;
    l_milestone_flag                                           := tasks.milestone_flag;
    l_holiday_flag                                             := tasks.holiday_flag;
    l_billable_flag                                            := tasks.billable_flag;
    l_bound_mode_code                                          := tasks.bound_mode_code;
    l_soft_bound_flag                                          := tasks.soft_bound_flag;
    l_notification_flag                                        := tasks.notification_flag;
    l_notification_period                                      := tasks.notification_period;
    l_notification_period_uom                                  := tasks.notification_period_uom;
    l_parent_task_id                                           := tasks.parent_task_id;
    l_alarm_start                                              := tasks.alarm_start;
    l_alarm_start_uom                                          := tasks.alarm_start_uom;
    l_alarm_on                                                 := tasks.alarm_on;
    l_alarm_count                                              := tasks.alarm_count;
    l_alarm_fired_count                                        := tasks.alarm_fired_count;
    l_alarm_interval                                           := tasks.alarm_interval;
    l_alarm_interval_uom                                       := tasks.alarm_interval_uom;
    l_palm_flag                                                := tasks.palm_flag;
    l_wince_flag                                               := tasks.wince_flag;
    l_laptop_flag                                              := tasks.laptop_flag;
    l_device1_flag                                             := tasks.device1_flag;
    l_device2_flag                                             := tasks.device2_flag;
    l_device3_flag                                             := tasks.device3_flag;
    l_costs                                                    := tasks.costs;
    l_currency_code                                            := tasks.currency_code;
    l_workflow_process_id                                      := tasks.workflow_process_id;
    l_escalation_level                                         := tasks.escalation_level;
    l_date_selected                                            := tasks.date_selected;
    l_free_busy_type                                           := p_free_busy_type;   --Bug No 4269468
    l_task_confirmation_status                                 := tasks.task_confirmation_status;
    l_task_confirmation_counter                                := tasks.task_confirmation_counter;
    l_task_split_flag                                          := tasks.task_split_flag;
    l_child_position                                           := tasks.child_position;
    l_child_sequence_num                                       := tasks.child_sequence_num;
    l_location_id                                              := tasks.location_id;
    -- ------------------------------------------------------------------------
    -- Call jtf_task_utl procedure to set calendar_start_date and
    -- calendar_end_date
    -- ------------------------------------------------------------------------
    jtf_task_utl_ext.set_calendar_dates(
      p_show_on_calendar           => p_show_on_calendar
    , p_date_selected              => tasks.date_selected
    , p_planned_start_date         => tasks.planned_start_date
    , p_planned_end_date           => tasks.planned_end_date
    , p_scheduled_start_date       => tasks.scheduled_start_date
    , p_scheduled_end_date         => tasks.scheduled_end_date
    , p_actual_start_date          => tasks.actual_start_date
    , p_actual_end_date            => tasks.actual_end_date
    , x_show_on_calendar           => l_show_on_calendar
    , x_date_selected              => l_date_selected
    , x_calendar_start_date        => l_calendar_start_date
    , x_calendar_end_date          => l_calendar_end_date
    , x_return_status              => x_return_status
    , p_task_status_id             => l_task_status_id
    , p_creation_date              => tasks.creation_date
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    --  Bug 2786689 : Fixing  Cyclic Task Issue
    IF (p_parent_task_id IS NOT NULL AND p_parent_task_id <> fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task(
        p_task_id                    => l_parent_task_id
      , p_task_number                => NULL
      , x_task_id                    => l_parent_task_id
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_utl_ext.validate_cyclic_task(
        p_task_id                    => l_task_id
      , p_parent_task_id             => l_parent_task_id
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    --- Validate Priority... Bug 3342819
    IF (l_task_priority_id = fnd_api.g_miss_num) OR(l_task_priority_id IS NULL) THEN
      l_task_priority_id  := 8;
    END IF;

    -- If workflow parameters is either NULL or fnd_api.g_miss_char,
    -- profile value for workflow will be used instead
    IF p_enable_workflow IS NULL OR p_enable_workflow = fnd_api.g_miss_char THEN
      l_enable_workflow  := g_enable_workflow;
    END IF;

    IF p_abort_workflow IS NULL OR p_abort_workflow = fnd_api.g_miss_char THEN
      l_abort_workflow  := g_abort_workflow;
    END IF;

    ------------------------------------------------------------
    -- Check if this is a repeating appointment
    ------------------------------------------------------------
    IF     tasks.recurrence_rule_id IS NOT NULL
       AND (
               tasks.source_object_type_code = 'APPOINTMENT'
            OR tasks.source_object_type_code = 'EXTERNAL APPOINTMENT'
           )
       AND NVL(p_change_mode, jtf_task_repeat_appt_pvt.g_skip) <> jtf_task_repeat_appt_pvt.g_skip THEN
      l_updated_field_rec.task_id                  := p_task_id;
      l_updated_field_rec.task_name                := p_task_name;
      l_updated_field_rec.task_type_id             := p_task_type_id;
      l_updated_field_rec.description              := p_description;
      l_updated_field_rec.task_status_id           := p_task_status_id;
      l_updated_field_rec.task_priority_id         := p_task_priority_id;
      l_updated_field_rec.owner_type_code          := p_owner_type_code;
      l_updated_field_rec.owner_id                 := p_owner_id;
      l_updated_field_rec.owner_territory_id       := p_owner_territory_id;
      l_updated_field_rec.assigned_by_id           := p_assigned_by_id;
      l_updated_field_rec.customer_id              := p_customer_id;
      l_updated_field_rec.cust_account_id          := p_cust_account_id;
      l_updated_field_rec.address_id               := p_address_id;
      l_updated_field_rec.planned_start_date       := p_planned_start_date;
      l_updated_field_rec.planned_end_date         := p_planned_end_date;
      l_updated_field_rec.scheduled_start_date     := p_scheduled_start_date;
      l_updated_field_rec.scheduled_end_date       := p_scheduled_end_date;
      l_updated_field_rec.actual_start_date        := p_actual_start_date;
      l_updated_field_rec.actual_end_date          := p_actual_end_date;
      l_updated_field_rec.timezone_id              := p_timezone_id;
      l_updated_field_rec.source_object_type_code  := p_source_object_type_code;
      l_updated_field_rec.source_object_id         := p_source_object_id;
      l_updated_field_rec.source_object_name       := p_source_object_name;
      l_updated_field_rec.DURATION                 := p_duration;
      l_updated_field_rec.duration_uom             := p_duration_uom;
      l_updated_field_rec.planned_effort           := p_planned_effort;
      l_updated_field_rec.planned_effort_uom       := p_planned_effort_uom;
      l_updated_field_rec.actual_effort            := p_actual_effort;
      l_updated_field_rec.actual_effort_uom        := p_actual_effort_uom;
      l_updated_field_rec.percentage_complete      := p_percentage_complete;
      l_updated_field_rec.reason_code              := p_reason_code;
      l_updated_field_rec.private_flag             := p_private_flag;
      l_updated_field_rec.publish_flag             := p_publish_flag;
      l_updated_field_rec.restrict_closure_flag    := p_restrict_closure_flag;
      l_updated_field_rec.multi_booked_flag        := p_multi_booked_flag;
      l_updated_field_rec.milestone_flag           := p_milestone_flag;
      l_updated_field_rec.holiday_flag             := p_holiday_flag;
      l_updated_field_rec.billable_flag            := p_billable_flag;
      l_updated_field_rec.bound_mode_code          := p_bound_mode_code;
      l_updated_field_rec.soft_bound_flag          := p_soft_bound_flag;
      l_updated_field_rec.workflow_process_id      := p_workflow_process_id;
      l_updated_field_rec.notification_flag        := p_notification_flag;
      l_updated_field_rec.notification_period      := p_notification_period;
      l_updated_field_rec.notification_period_uom  := p_notification_period_uom;
      l_updated_field_rec.parent_task_id           := p_parent_task_id;
      l_updated_field_rec.alarm_start              := p_alarm_start;
      l_updated_field_rec.alarm_start_uom          := p_alarm_start_uom;
      l_updated_field_rec.alarm_on                 := p_alarm_on;
      l_updated_field_rec.alarm_count              := p_alarm_count;
      l_updated_field_rec.alarm_fired_count        := p_alarm_fired_count;
      l_updated_field_rec.alarm_interval           := p_alarm_interval;
      l_updated_field_rec.alarm_interval_uom       := p_alarm_interval_uom;
      l_updated_field_rec.palm_flag                := p_palm_flag;
      l_updated_field_rec.wince_flag               := p_wince_flag;
      l_updated_field_rec.laptop_flag              := p_laptop_flag;
      l_updated_field_rec.device1_flag             := p_device1_flag;
      l_updated_field_rec.device2_flag             := p_device2_flag;
      l_updated_field_rec.device3_flag             := p_device3_flag;
      l_updated_field_rec.costs                    := p_costs;
      l_updated_field_rec.currency_code            := p_currency_code;
      l_updated_field_rec.escalation_level         := p_escalation_level;
      l_updated_field_rec.attribute1               := p_attribute1;
      l_updated_field_rec.attribute2               := p_attribute2;
      l_updated_field_rec.attribute3               := p_attribute3;
      l_updated_field_rec.attribute4               := p_attribute4;
      l_updated_field_rec.attribute5               := p_attribute5;
      l_updated_field_rec.attribute6               := p_attribute6;
      l_updated_field_rec.attribute7               := p_attribute7;
      l_updated_field_rec.attribute8               := p_attribute8;
      l_updated_field_rec.attribute9               := p_attribute9;
      l_updated_field_rec.attribute10              := p_attribute10;
      l_updated_field_rec.attribute11              := p_attribute11;
      l_updated_field_rec.attribute12              := p_attribute12;
      l_updated_field_rec.attribute13              := p_attribute13;
      l_updated_field_rec.attribute14              := p_attribute14;
      l_updated_field_rec.attribute15              := p_attribute15;
      l_updated_field_rec.attribute_category       := p_attribute_category;
      l_updated_field_rec.date_selected            := p_date_selected;
      l_updated_field_rec.category_id              := p_category_id;
      l_updated_field_rec.show_on_calendar         := p_show_on_calendar;
      l_updated_field_rec.owner_status_id          := p_owner_status_id;
      l_updated_field_rec.enable_workflow          := l_enable_workflow;
      l_updated_field_rec.abort_workflow           := l_abort_workflow;
      l_updated_field_rec.change_mode              := p_change_mode;
      l_updated_field_rec.recurrence_rule_id       := tasks.recurrence_rule_id;
      l_updated_field_rec.old_calendar_start_date  := tasks.calendar_start_date;
      l_updated_field_rec.new_calendar_start_date  := l_calendar_start_date;
      l_updated_field_rec.new_calendar_end_date    := l_calendar_end_date;
      l_updated_field_rec.free_busy_type           := l_free_busy_type;   -- Bug No 4269468
      l_updated_field_rec.location_id              := p_location_id;
      jtf_task_repeat_appt_pvt.update_repeat_appointment
                                               (
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_object_version_number      => p_object_version_number
      , p_updated_field_rec          => l_updated_field_rec
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      RETURN;
    END IF;

    -- ------------------------------------------------------------------------
    -- If date_selected was not present then set the appropriate dates
    -- depending on date_selected returned from set_calendar_dates, to fix
    -- bug #1889371
    -- ------------------------------------------------------------------------
    IF tasks.date_selected IS NULL OR tasks.date_selected = fnd_api.g_miss_char THEN
      IF l_date_selected = 'P' THEN
        l_planned_start_date  := l_calendar_start_date;
        l_planned_end_date    := l_calendar_end_date;
      ELSIF l_date_selected = 'S' THEN
        l_scheduled_start_date  := l_calendar_start_date;
        l_scheduled_end_date    := l_calendar_end_date;
      ELSIF l_date_selected = 'A' THEN
        l_actual_start_date  := l_calendar_start_date;
        l_actual_end_date    := l_calendar_end_date;
      END IF;
    END IF;

    -- ------------------------------------------------------------------------
    -- If type is Appointment then set scheduled dates to the value of the
    -- planned dates, to fix bug #1889178
    -- ------------------------------------------------------------------------
    IF p_source_object_type_code = 'APPOINTMENT' THEN
      l_scheduled_start_date  := l_planned_start_date;
      l_scheduled_end_date    := l_planned_end_date;
    END IF;

    -- ------------------------------------------------------------------------
    -- If source is Task or Appointment then set source_id to task_id and
    -- source_name to task_number
    -- Do not update these values if source_object_type_code is not supplied as
    -- a parameter to the update, to fix bug #1935825
    -- Also retain original values if source_object_type_code is NULL - this is
    -- handled in the DECODE above, so no need to check for it here as
    -- tasks.source_object_type_code will always have a value.
    -- ------------------------------------------------------------------------
    IF tasks.source_object_type_code IN('TASK', 'APPOINTMENT') THEN
      l_source_object_id    := l_task_id;
      l_source_object_name  := tasks.task_number;
    ELSE
      l_source_object_id    := tasks.source_object_id;
      -- Bug 2602732
      l_source_object_name  :=
        jtf_task_utl.check_truncation(jtf_task_utl.get_owner(tasks.source_object_type_code
          , l_source_object_id));
    END IF;

    -- ------------------------------------------------------------------------
    -- Get the original customer_id so we can update the reference details if
    -- necessary
    -- ------------------------------------------------------------------------
    OPEN task_cust_orig(l_task_id);
    FETCH task_cust_orig INTO l_orig_cust_id;
    IF task_cust_orig%NOTFOUND THEN
      CLOSE task_cust_orig;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE task_cust_orig;

    -- 2102281
    OPEN task_source_orig(l_task_id);
    FETCH task_source_orig INTO l_orig_source_id, l_orig_source_object_type_code, l_entity, l_orig_open_flag;
    IF task_source_orig%NOTFOUND THEN
      CLOSE task_source_orig;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    CLOSE task_source_orig;

    jtf_tasks_pub.p_task_user_hooks.task_id                    := l_task_id;
    jtf_tasks_pub.p_task_user_hooks.task_number                := l_task_number;
    jtf_tasks_pub.p_task_user_hooks.task_name                  := l_task_name;
    jtf_tasks_pub.p_task_user_hooks.task_type_id               := l_task_type_id;
    jtf_tasks_pub.p_task_user_hooks.description                := l_description;
    jtf_tasks_pub.p_task_user_hooks.task_status_id             := l_task_status_id;
    jtf_tasks_pub.p_task_user_hooks.task_priority_id           := l_task_priority_id;
    jtf_tasks_pub.p_task_user_hooks.owner_type_code            := l_owner_type_code;
    jtf_tasks_pub.p_task_user_hooks.owner_id                   := l_owner_id;
    jtf_tasks_pub.p_task_user_hooks.owner_territory_id         := tasks.owner_territory_id;
    jtf_tasks_pub.p_task_user_hooks.assigned_by_id             := l_assigned_by_id;
    jtf_tasks_pub.p_task_user_hooks.customer_id                := l_customer_id;
    jtf_tasks_pub.p_task_user_hooks.cust_account_id            := l_cust_account_id;
    jtf_tasks_pub.p_task_user_hooks.address_id                 := l_address_id;
    jtf_tasks_pub.p_task_user_hooks.planned_start_date         := l_planned_start_date;
    jtf_tasks_pub.p_task_user_hooks.planned_end_date           := l_planned_end_date;
    jtf_tasks_pub.p_task_user_hooks.scheduled_start_date       := l_scheduled_start_date;
    jtf_tasks_pub.p_task_user_hooks.scheduled_end_date         := l_scheduled_end_date;
    jtf_tasks_pub.p_task_user_hooks.actual_start_date          := l_actual_start_date;
    jtf_tasks_pub.p_task_user_hooks.actual_end_date            := l_actual_end_date;
    jtf_tasks_pub.p_task_user_hooks.timezone_id                := l_timezone_id;
    jtf_tasks_pub.p_task_user_hooks.source_object_type_code    := tasks.source_object_type_code;
    jtf_tasks_pub.p_task_user_hooks.source_object_id           := l_source_object_id;
    jtf_tasks_pub.p_task_user_hooks.source_object_name         := l_source_object_name;
    jtf_tasks_pub.p_task_user_hooks.DURATION                   := l_duration;
    jtf_tasks_pub.p_task_user_hooks.duration_uom               := l_duration_uom;
    jtf_tasks_pub.p_task_user_hooks.planned_effort             := l_planned_effort;
    jtf_tasks_pub.p_task_user_hooks.planned_effort_uom         := l_planned_effort_uom;
    jtf_tasks_pub.p_task_user_hooks.actual_effort              := l_actual_effort;
    jtf_tasks_pub.p_task_user_hooks.actual_effort_uom          := l_actual_effort_uom;
    jtf_tasks_pub.p_task_user_hooks.percentage_complete        := l_percentage_complete;
    jtf_tasks_pub.p_task_user_hooks.reason_code                := l_reason_code;
    jtf_tasks_pub.p_task_user_hooks.private_flag               := l_private_flag;
    jtf_tasks_pub.p_task_user_hooks.publish_flag               := l_publish_flag;
    jtf_tasks_pub.p_task_user_hooks.restrict_closure_flag      := l_restrict_closure_flag;
    jtf_tasks_pub.p_task_user_hooks.multi_booked_flag          := l_multi_booked_flag;
    jtf_tasks_pub.p_task_user_hooks.milestone_flag             := l_milestone_flag;
    jtf_tasks_pub.p_task_user_hooks.holiday_flag               := l_holiday_flag;
    jtf_tasks_pub.p_task_user_hooks.billable_flag              := l_billable_flag;
    jtf_tasks_pub.p_task_user_hooks.bound_mode_code            := l_bound_mode_code;
    jtf_tasks_pub.p_task_user_hooks.soft_bound_flag            := l_soft_bound_flag;
    jtf_tasks_pub.p_task_user_hooks.workflow_process_id        := l_workflow_process_id;
    jtf_tasks_pub.p_task_user_hooks.notification_flag          := l_notification_flag;
    jtf_tasks_pub.p_task_user_hooks.notification_period        := l_notification_period;
    jtf_tasks_pub.p_task_user_hooks.notification_period_uom    := l_notification_period_uom;
    jtf_tasks_pub.p_task_user_hooks.parent_task_id             := l_parent_task_id;
    jtf_tasks_pub.p_task_user_hooks.alarm_start                := l_alarm_start;
    jtf_tasks_pub.p_task_user_hooks.alarm_start_uom            := l_alarm_start_uom;
    jtf_tasks_pub.p_task_user_hooks.alarm_on                   := l_alarm_on;
    jtf_tasks_pub.p_task_user_hooks.alarm_count                := l_alarm_count;
    jtf_tasks_pub.p_task_user_hooks.alarm_interval             := l_alarm_interval;
    jtf_tasks_pub.p_task_user_hooks.alarm_interval_uom         := l_alarm_interval_uom;
    jtf_tasks_pub.p_task_user_hooks.palm_flag                  := l_palm_flag;
    jtf_tasks_pub.p_task_user_hooks.wince_flag                 := l_wince_flag;
    jtf_tasks_pub.p_task_user_hooks.laptop_flag                := l_laptop_flag;
    jtf_tasks_pub.p_task_user_hooks.device1_flag               := l_device1_flag;
    jtf_tasks_pub.p_task_user_hooks.device2_flag               := l_device2_flag;
    jtf_tasks_pub.p_task_user_hooks.device3_flag               := l_device3_flag;
    jtf_tasks_pub.p_task_user_hooks.costs                      := l_costs;
    jtf_tasks_pub.p_task_user_hooks.currency_code              := l_currency_code;
    jtf_tasks_pub.p_task_user_hooks.escalation_level           := l_escalation_level;
    jtf_tasks_pub.p_task_user_hooks.date_selected              := l_date_selected;
    jtf_tasks_pub.p_task_user_hooks.attribute1                 := tasks.attribute1;
    jtf_tasks_pub.p_task_user_hooks.attribute2                 := tasks.attribute2;
    jtf_tasks_pub.p_task_user_hooks.attribute3                 := tasks.attribute3;
    jtf_tasks_pub.p_task_user_hooks.attribute4                 := tasks.attribute4;
    jtf_tasks_pub.p_task_user_hooks.attribute5                 := tasks.attribute5;
    jtf_tasks_pub.p_task_user_hooks.attribute6                 := tasks.attribute6;
    jtf_tasks_pub.p_task_user_hooks.attribute7                 := tasks.attribute7;
    jtf_tasks_pub.p_task_user_hooks.attribute8                 := tasks.attribute8;
    jtf_tasks_pub.p_task_user_hooks.attribute9                 := tasks.attribute9;
    jtf_tasks_pub.p_task_user_hooks.attribute10                := tasks.attribute10;
    jtf_tasks_pub.p_task_user_hooks.attribute11                := tasks.attribute11;
    jtf_tasks_pub.p_task_user_hooks.attribute12                := tasks.attribute12;
    jtf_tasks_pub.p_task_user_hooks.attribute13                := tasks.attribute13;
    jtf_tasks_pub.p_task_user_hooks.attribute14                := tasks.attribute14;
    jtf_tasks_pub.p_task_user_hooks.attribute15                := tasks.attribute15;
    jtf_tasks_pub.p_task_user_hooks.attribute_category         := tasks.attribute_category;
    jtf_tasks_pub.p_task_user_hooks.entity                     := l_entity;
    jtf_tasks_pub.p_task_user_hooks.task_confirmation_status   := l_task_confirmation_status;
    jtf_tasks_pub.p_task_user_hooks.task_confirmation_counter  := l_task_confirmation_counter;
    jtf_tasks_pub.p_task_user_hooks.task_split_flag            := l_task_split_flag;
    jtf_tasks_pub.p_task_user_hooks.child_position             := l_child_position;
    jtf_tasks_pub.p_task_user_hooks.child_sequence_num         := l_child_sequence_num;
    jtf_tasks_pub.p_task_user_hooks.open_flag                  := l_orig_open_flag;
    jtf_tasks_pub.p_task_user_hooks.location_id                := l_location_id;
    jtf_tasks_iuhk.update_task_pre(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    jtf_tasks_pub.lock_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => l_task_id
    , p_object_version_number      => p_object_version_number
    , x_return_status              => x_return_status
    , x_msg_data                   => x_msg_data
    , x_msg_count                  => x_msg_count
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

          ---------------------------------------------------------
          -- When a user update repeating task for all the future
          --   appointment, then we create a new recurrence rule.
          -- In this case we need to update the recurrence_rule_id
          --  for all the future appointment.
          ---------------------------------------------------------
    --BES changes to call the new jtf_tasks_pkg.update_row
    x_task_upd_rec.task_id                                     := l_task_id;
    x_task_upd_rec.object_version_number                       := p_object_version_number + 1;
    x_task_upd_rec.laptop_flag                                 := l_laptop_flag;
    x_task_upd_rec.device1_flag                                := l_device1_flag;
    x_task_upd_rec.device2_flag                                := l_device2_flag;
    x_task_upd_rec.device3_flag                                := l_device3_flag;
    x_task_upd_rec.currency_code                               := l_currency_code;
    x_task_upd_rec.costs                                       := l_costs;
    x_task_upd_rec.attribute1                                  := tasks.attribute1;
    x_task_upd_rec.attribute2                                  := tasks.attribute2;
    x_task_upd_rec.attribute3                                  := tasks.attribute3;
    x_task_upd_rec.attribute4                                  := tasks.attribute4;
    x_task_upd_rec.attribute5                                  := tasks.attribute5;
    x_task_upd_rec.attribute6                                  := tasks.attribute6;
    x_task_upd_rec.attribute7                                  := tasks.attribute7;
    x_task_upd_rec.attribute8                                  := tasks.attribute8;
    x_task_upd_rec.attribute9                                  := tasks.attribute9;
    x_task_upd_rec.attribute10                                 := tasks.attribute10;
    x_task_upd_rec.attribute11                                 := tasks.attribute11;
    x_task_upd_rec.attribute12                                 := tasks.attribute12;
    x_task_upd_rec.attribute13                                 := tasks.attribute13;
    x_task_upd_rec.attribute14                                 := tasks.attribute14;
    x_task_upd_rec.attribute15                                 := tasks.attribute15;
    x_task_upd_rec.attribute_category                          := tasks.attribute_category;
    x_task_upd_rec.task_number                                 := l_task_number;
    x_task_upd_rec.task_type_id                                := l_task_type_id;
    x_task_upd_rec.task_status_id                              := l_task_status_id;
    x_task_upd_rec.task_priority_id                            := l_task_priority_id;
    x_task_upd_rec.owner_id                                    := l_owner_id;
    x_task_upd_rec.owner_type_code                             := l_owner_type_code;
    x_task_upd_rec.owner_territory_id                          := tasks.owner_territory_id;
    x_task_upd_rec.assigned_by_id                              := l_assigned_by_id;
    x_task_upd_rec.cust_account_id                             := l_cust_account_id;
    x_task_upd_rec.customer_id                                 := l_customer_id;
    x_task_upd_rec.address_id                                  := l_address_id;
    x_task_upd_rec.planned_start_date                          := l_planned_start_date;
    x_task_upd_rec.planned_end_date                            := l_planned_end_date;
    x_task_upd_rec.scheduled_start_date                        := l_scheduled_start_date;
    x_task_upd_rec.scheduled_end_date                          := l_scheduled_end_date;
    x_task_upd_rec.actual_start_date                           := l_actual_start_date;
    x_task_upd_rec.actual_end_date                             := l_actual_end_date;
    x_task_upd_rec.source_object_type_code                     := tasks.source_object_type_code;
    x_task_upd_rec.timezone_id                                 := l_timezone_id;
    x_task_upd_rec.source_object_id                            := l_source_object_id;
    x_task_upd_rec.source_object_name                          := l_source_object_name;
    x_task_upd_rec.DURATION                                    := l_duration;
    x_task_upd_rec.duration_uom                                := l_duration_uom;
    x_task_upd_rec.planned_effort                              := l_planned_effort;
    x_task_upd_rec.planned_effort_uom                          := l_planned_effort_uom;
    x_task_upd_rec.actual_effort                               := l_actual_effort;
    x_task_upd_rec.actual_effort_uom                           := l_actual_effort_uom;
    x_task_upd_rec.percentage_complete                         := l_percentage_complete;
    x_task_upd_rec.reason_code                                 := l_reason_code;
    x_task_upd_rec.private_flag                                := l_private_flag;
    x_task_upd_rec.publish_flag                                := l_publish_flag;
    x_task_upd_rec.restrict_closure_flag                       := l_restrict_closure_flag;
    x_task_upd_rec.multi_booked_flag                           := l_multi_booked_flag;
    x_task_upd_rec.milestone_flag                              := l_milestone_flag;
    x_task_upd_rec.holiday_flag                                := l_holiday_flag;
    x_task_upd_rec.billable_flag                               := l_billable_flag;
    x_task_upd_rec.bound_mode_code                             := l_bound_mode_code;
    x_task_upd_rec.soft_bound_flag                             := l_soft_bound_flag;
    x_task_upd_rec.workflow_process_id                         := l_workflow_process_id;
    x_task_upd_rec.notification_flag                           := l_notification_flag;
    x_task_upd_rec.notification_period                         := l_notification_period;
    x_task_upd_rec.notification_period_uom                     := l_notification_period_uom;
    x_task_upd_rec.parent_task_id                              := l_parent_task_id;
    x_task_upd_rec.recurrence_rule_id                          := tasks.recurrence_rule_id;
    x_task_upd_rec.alarm_start                                 := l_alarm_start;
    x_task_upd_rec.alarm_start_uom                             := l_alarm_start_uom;
    x_task_upd_rec.alarm_on                                    := l_alarm_on;
    x_task_upd_rec.alarm_count                                 := l_alarm_count;
    x_task_upd_rec.alarm_fired_count                           := l_alarm_fired_count;
    x_task_upd_rec.alarm_interval                              := l_alarm_interval;
    x_task_upd_rec.alarm_interval_uom                          := l_alarm_interval_uom;
    x_task_upd_rec.deleted_flag                                := 'N';
    x_task_upd_rec.palm_flag                                   := l_palm_flag;
    x_task_upd_rec.wince_flag                                  := l_wince_flag;
    x_task_upd_rec.task_name                                   := l_task_name;
    x_task_upd_rec.description                                 := l_description;
    x_task_upd_rec.last_update_date                            := SYSDATE;
    x_task_upd_rec.last_updated_by                             := jtf_task_utl.updated_by;
    x_task_upd_rec.last_update_login                           := jtf_task_utl.login_id;
    x_task_upd_rec.escalation_level                            := l_escalation_level;
    x_task_upd_rec.calendar_start_date                         := l_calendar_start_date;
    x_task_upd_rec.calendar_end_date                           := l_calendar_end_date;
    x_task_upd_rec.date_selected                               := l_date_selected;
    x_task_upd_rec.open_flag                                   := jtf_task_utl_ext.get_open_flag(l_task_status_id);
    x_task_upd_rec.task_confirmation_status                    := l_task_confirmation_status;
    x_task_upd_rec.task_confirmation_counter                   := l_task_confirmation_counter;
    x_task_upd_rec.task_split_flag                             := l_task_split_flag;
    x_task_upd_rec.child_position                              := l_child_position;
    x_task_upd_rec.child_sequence_num                          := l_child_sequence_num;
    x_task_upd_rec.location_id                                 := l_location_id;
    jtf_tasks_pkg.update_row(p_task_upd_rec => x_task_upd_rec, p_task_audit_id => x_task_audit_id);


    ---------------
    ---------------  validate and get value for owner_status_id
    ---------------
    /* modified validation to default owner assignmetn status based on profile if passed value is not a valid
            * assignment status*/
    IF p_owner_status_id IS NOT NULL AND p_owner_status_id <> fnd_api.g_miss_num THEN
      OPEN c_owner_status_id(p_owner_status_id);

      FETCH c_owner_status_id
       INTO l_owner_status_id;

      IF c_owner_status_id%NOTFOUND THEN
        CLOSE c_owner_status_id;
        /*Modified  for Bug# 8574559 */
        l_owner_status_id  := NVL(fnd_profile.VALUE(NAME => 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'), 3);
      ELSE
        CLOSE c_owner_status_id;
      END IF;
    ELSE
      -- Added NVL on 08/08/2006 for bug# 5452407
      l_owner_status_id  := NVL(fnd_profile.VALUE(NAME => 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'), 3);
    END IF;

    -- ------------------------------------------------------------------------
    -- Update task assignment for Owner if changed
    -- ------------------------------------------------------------------------
    OPEN task_ass_orig(l_task_id);
    FETCH task_ass_orig INTO task_ass_orig_rec;
    IF ((task_ass_orig%NOTFOUND) OR(task_ass_orig_rec.assignee_role <> 'OWNER')) THEN
      CLOSE task_ass_orig;   -- Fix a missing CLOSE on 4/18/2002

      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_OWNER_ASG');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- CLOSE task_ass_orig; -- Fix a missing CLOSE on 4/18/2002   -- Commented out on 19/06/2006 for bug# 5210853
    IF    (
               NVL(p_owner_id, 0) <> fnd_api.g_miss_num
           AND NVL(p_owner_id, 0) <> task_ass_orig_rec.resource_id
          )
       OR (
               NVL(p_category_id, 0) <> jtf_task_utl.g_miss_number
           AND NVL(p_category_id, 0) <> NVL(task_ass_orig_rec.category_id, 0)
          )
       OR (
               NVL(l_show_on_calendar, 'X') <> fnd_api.g_miss_char
           AND NVL(l_show_on_calendar, 'X') <> NVL(task_ass_orig_rec.show_on_calendar, 'X')
          )
       OR (
               NVL(x_task_upd_rec.open_flag, 'X') <> fnd_api.g_miss_char
           AND NVL(x_task_upd_rec.open_flag, 'X') <> NVL(l_orig_open_flag, 'X')
          )
       OR (
               NVL(l_free_busy_type, 'X') <> jtf_task_utl.g_miss_char
           AND NVL(l_free_busy_type, 'X') <> NVL(task_ass_orig_rec.free_busy_type, 'X')
          )
       OR
           -- Commented out this part of the code since it's no more required after fixing bug# 5210853
          /* --Added by SBARAT on 26/04/2005 for Bug# 4122322
          (nvl(p_scheduled_start_date, sysdate) <> fnd_api.g_miss_date and
           nvl(p_scheduled_start_date, sysdate) <> nvl(task_ass_orig_rec.booking_start_date, sysdate)) or
          (nvl(p_scheduled_end_date, sysdate) <> fnd_api.g_miss_date and
           nvl(p_scheduled_end_date, sysdate) <> nvl(task_ass_orig_rec.booking_end_date, sysdate)) or
           --End of addition by SBARAT on 26/04/2005 for Bug# 4122322 */

          -- Start of addition on 19/06/2006 for bug# 5210853
          (
               (
                   (NVL(l_calendar_start_date, SYSDATE) <> NVL(tasks.calendar_start_date, SYSDATE))
                OR (NVL(l_calendar_end_date, SYSDATE) <> NVL(tasks.calendar_end_date, SYSDATE))
               )
           AND (
                   (task_ass_orig_rec.actual_start_date IS NULL)
                OR (task_ass_orig_rec.actual_end_date IS NULL)
               )
          )
       OR (NVL(l_actual_start_date, SYSDATE) <> NVL(task_ass_orig_rec.actual_start_date, SYSDATE))
       OR (NVL(l_actual_end_date, SYSDATE) <> NVL(task_ass_orig_rec.actual_end_date, SYSDATE))
       OR
          -- End of addition on 19/06/2006 for bug# 5210853
          (
               NVL(l_owner_status_id, 0) <> fnd_api.g_miss_num
           AND NVL(l_owner_status_id, 0) <> NVL(task_ass_orig_rec.assignment_status_id, 0)
          ) THEN
      OPEN task_ass_u(l_task_id);

      FETCH task_ass_u
       INTO task_ass_rec;

      IF task_ass_u%NOTFOUND THEN
        CLOSE task_ass_orig;

        CLOSE task_ass_u;   -- Fix a missing CLOSE on 4/18/2002

        fnd_message.set_name('JTF', 'JTF_TASK_MISSING_OWNER_ASG');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE task_ass_u;   -- Fix a missing CLOSE on 4/18/2002

      jtf_task_assignments_pvt.g_response_flag  := jtf_task_utl.g_yes_char;   -- Fix bug# 2375153
      jtf_task_assignments_pvt.update_task_assignment(
        p_api_version                => p_api_version
      , p_object_version_number      => task_ass_rec.object_version_number
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_assignment_id         => task_ass_rec.task_assignment_id
      , p_actual_start_date          => l_actual_start_date
      , p_actual_end_date            => l_actual_end_date
      , p_palm_flag                  => l_palm_flag
      , p_wince_flag                 => l_wince_flag
      , p_laptop_flag                => l_laptop_flag
      , p_device1_flag               => l_device1_flag
      , p_device2_flag               => l_device2_flag
      , p_device3_flag               => l_device3_flag
      , p_resource_id                => task_ass_rec.resource_id
      , p_actual_effort              => l_actual_effort
      , p_actual_effort_uom          => l_actual_effort_uom
      , p_resource_type_code         => task_ass_rec.resource_type_code
      , p_resource_territory_id      => task_ass_rec.resource_territory_id
      , p_assignment_status_id       => task_ass_rec.assignment_status_id
      , x_msg_data                   => x_msg_data
      , x_msg_count                  => x_msg_count
      , x_return_status              => x_return_status
      , p_assignee_role              => 'OWNER'
      , p_show_on_calendar           => task_ass_rec.show_on_calendar
      , p_category_id                => task_ass_rec.category_id
      , p_enable_workflow            => l_enable_workflow
      , p_abort_workflow             => l_abort_workflow
      , p_free_busy_type             => task_ass_rec.free_busy_type
      );
      /*************************************************************************
        -- Bug 2467222  for assignee category update
        OPEN  jtf_task_utl.c_assignee_or_owner (l_task_id,p_category_id);
        FETCH jtf_task_utl.c_assignee_or_owner INTO l_assignee_rec;
        CLOSE jtf_task_utl.c_assignee_or_owner;

      jtf_task_utl.update_task_category(
            p_api_version => p_api_version,
            p_object_version_number => l_assignee_rec.object_version_number,
            p_task_assignment_id   => l_assignee_rec.task_assignment_id,
      p_category_id => p_category_id,
            x_msg_data => x_msg_data,
      x_msg_count => x_msg_count,
      x_return_status => x_return_status);
      ***************************************************************************/
      jtf_task_assignments_pvt.g_response_flag  := jtf_task_utl.g_no_char;   -- Fix bug# 2375153

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        CLOSE task_ass_orig;

        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -- Start of addition on 19/06/2006 for bug# 5210853
    LOOP
      task_ass_orig_rec  := NULL;

      FETCH task_ass_orig INTO task_ass_orig_rec;

      IF task_ass_orig%NOTFOUND THEN
        CLOSE task_ass_orig;
        EXIT;
      END IF;

      IF (
              (task_ass_orig_rec.assignee_role = 'ASSIGNEE')
          AND (
                  (NVL(l_calendar_start_date, SYSDATE) <> NVL(tasks.calendar_start_date, SYSDATE))
               OR (NVL(l_calendar_end_date, SYSDATE) <> NVL(tasks.calendar_end_date, SYSDATE))
              )
          AND (
                  (task_ass_orig_rec.actual_start_date IS NULL)
               OR (task_ass_orig_rec.actual_end_date IS NULL)
              )
         ) THEN
        -- Added for Bug 6031383 . Directly updating the assignment to avoid
        -- object version number change of the assignment.
        jtf_task_assignments_pvt.populate_booking_dates
                     (
          p_calendar_start_date        => l_calendar_start_date
        , p_calendar_end_date          => l_calendar_end_date
        , p_actual_start_date          => task_ass_orig_rec.actual_start_date
        , p_actual_end_date            => task_ass_orig_rec.actual_end_date
        , p_actual_travel_duration     => task_ass_orig_rec.actual_travel_duration
        , p_actual_travel_duration_uom => task_ass_orig_rec.actual_travel_duration_uom
        , p_planned_effort             => l_planned_effort
        , p_planned_effort_uom         => l_planned_effort_uom
        , p_actual_effort              => task_ass_orig_rec.actual_effort
        , p_actual_effort_uom          => task_ass_orig_rec.actual_effort_uom
        , x_booking_start_date         => l_booking_start_date
        , x_booking_end_date           => l_booking_end_date
        );

        UPDATE jtf_task_all_assignments
           SET booking_start_date = l_booking_start_date
             , booking_end_date = l_booking_end_date
         WHERE task_assignment_id = task_ass_orig_rec.task_assignment_id;
      END IF;
    END LOOP;

    -- End of addition on 19/06/2006 for bug# 5210853

    -- 2102281
    --------------------------------------------------------------
      -- ------------------------------------------------------------------------
      -- Update reference to source if changed, fix enh # 2102281
      -- ------------------------------------------------------------------------
    jtf_task_utl_ext.update_object_code(
      p_task_id                    => l_task_id
    , p_old_object_code            => l_orig_source_object_type_code
    , p_new_object_code            => tasks.source_object_type_code
    , p_old_object_id              => l_orig_source_id
    , p_new_object_id              => l_source_object_id
    , p_new_object_name            => l_source_object_name
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --------------------------------------------------------------

    -- ------------------------------------------------------------------------
    -- Update reference to customer if changed, fix enh #1845501
    -- ------------------------------------------------------------------------
    IF (
        NVL(l_customer_id, 0) <> fnd_api.g_miss_num
        AND NVL(l_customer_id, 0) <> NVL(l_orig_cust_id, 0)
       ) THEN
      -- Added for Bug# 2593974
      -------------------------------------------------
      ------ delete contacts and related contact points
      -------------------------------------------------
      FOR c IN c_del_contacts(l_task_id) LOOP
        jtf_task_contacts_pub.delete_task_contacts
                                               (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => c.object_version_number
        , p_task_contact_id            => c.task_contact_id
        , x_return_status              => x_return_status
        , x_msg_data                   => x_msg_data
        , x_msg_count                  => x_msg_count
        , p_delete_cascade             => jtf_task_utl.g_yes_char
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      -- End Add

      -- delete the old one
      jtf_task_utl.delete_party_reference(
        p_reference_from             => 'TASK'
      , p_task_id                    => l_task_id
      , p_party_id                   => l_orig_cust_id
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- create a new one
      jtf_task_utl.create_party_reference(
        p_reference_from             => 'TASK'
      , p_task_id                    => l_task_id
      , p_party_id                   => l_customer_id
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    jtf_tasks_iuhk.update_task_post(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Increment the object version number to be returned
    p_object_version_number                                    := p_object_version_number + 1;
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    --BES enh 2391065
    IF (l_entity = 'TASK') THEN
      l_task_rec_type_old.source_object_type_code  := l_orig_source_object_type_code;
      l_task_rec_type_old.source_object_id         := l_orig_source_id;
      l_task_rec_type_new.task_id                  := l_task_id;
      l_task_rec_type_new.task_audit_id            := x_task_audit_id;
      l_task_rec_type_new.source_object_type_code  := tasks.source_object_type_code;
      l_task_rec_type_new.source_object_id         := l_source_object_id;
      l_task_rec_type_new.enable_workflow          := l_enable_workflow;
      l_task_rec_type_new.abort_workflow           := l_abort_workflow;
      jtf_task_wf_events_pvt.publish_update_task(
        p_task_rec_old               => l_task_rec_type_old
      , p_task_rec_new               => l_task_rec_type_new
      , x_return_status              => x_event_return_status
      );

      IF (x_event_return_status = 'WARNING') THEN
        fnd_message.set_name('JTF', 'JTF_TASK_EVENT_WARNING');
        fnd_message.set_token('P_TASK_ID', l_task_id);
        fnd_msg_pub.ADD;
      ELSIF(x_event_return_status = 'ERROR') THEN
        fnd_message.set_name('JTF', 'JTF_TASK_EVENT_ERROR');
        fnd_message.set_token('P_TASK_ID', l_task_id);
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  --BES enh 2391065
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pvt;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pvt;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;   ---- End of private Update Task

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
  ) IS
  BEGIN
    SAVEPOINT delete_task_pvt2;
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Added by lokumar for bug#6598081
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Call the new version
    delete_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_delete_future_recurrences  => p_delete_future_recurrences
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
    , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_task_pvt2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_task_pvt2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- New version
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
  ) IS
    l_task_id                      jtf_tasks_b.task_id%TYPE                       := p_task_id;
    l_recur_rule                   jtf_task_recur_rules.recurrence_rule_id%TYPE;
    l_date_selected                jtf_task_recur_rules.date_selected%TYPE;
    l_planned_date                 jtf_tasks_b.planned_start_date%TYPE;
    l_scheduled_date               jtf_tasks_b.scheduled_start_date%TYPE;
    l_actual_date                  jtf_tasks_b.actual_start_date%TYPE;
    l_obj_version                  jtf_tasks_b.object_version_number%TYPE;
    l_source_object_type_code      jtf_tasks_b.source_object_type_code%TYPE;
    l_source_object_id             jtf_tasks_b.source_object_id%TYPE;
    l_calendar_start_date          DATE;
    l_task_exclusion_id            NUMBER;
    l_parent_child_count           NUMBER;

    -- ------------------------------------------------------------------------
    -- Retrieve recurrence rule id for the selected task, plus the start dates
    -- for that task, to fix bug #1975337
    -- ------------------------------------------------------------------------
    CURSOR c_recur_rule(b_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT recurrence_rule_id
           , planned_start_date
           , scheduled_start_date
           , actual_start_date
        FROM jtf_tasks_b
       WHERE task_id = b_task_id;

    -- ------------------------------------------------------------------------
    -- Retrieve date used in recurrence rule
    -- ------------------------------------------------------------------------
    CURSOR c_recur_date(b_rule_id jtf_tasks_b.recurrence_rule_id%TYPE) IS
      SELECT date_selected
        FROM jtf_task_recur_rules
       WHERE recurrence_rule_id = b_rule_id;

    -- ------------------------------------------------------------------------
    -- Capture all future recurrences if p_delete_future_recurrences is TRUE,
    -- or all past and future recurrences if p_delete_future_recurrences is 'A'
    -- ------------------------------------------------------------------------
    CURSOR c_delete_task(b_date_selected jtf_task_recur_rules.date_selected%TYPE) IS
      SELECT task_id
           , object_version_number
           , source_object_type_code
           ,   -- Added for XP Sync Story #58
             calendar_start_date   -- Added for XP Sync Story #58
        FROM jtf_tasks_b
       WHERE task_id = p_task_id
      UNION ALL
      SELECT task_id
           , object_version_number
           , source_object_type_code
           ,   -- Added for XP Sync Story #58
             calendar_start_date   -- Added for XP Sync Story #58
        FROM jtf_tasks_b
       WHERE recurrence_rule_id = l_recur_rule
         AND (
                 (
                      p_delete_future_recurrences = fnd_api.g_true
                  AND (

                          ---------------------------
                          ---- 'P' use planned date
                          ---- null (existing data)
                          ---- also use planned date
                          ---------------------------
                          (NVL(b_date_selected, 'P') = 'P' AND planned_start_date >= l_planned_date)
                       OR
                          ---------------------------
                          ---- 'S' use scheduled date
                          ---------------------------
                          (b_date_selected = 'S' AND scheduled_start_date >= l_scheduled_date)
                       OR
                          ---------------------------
                          ---- 'A' use actual date
                          ---------------------------
                          (b_date_selected = 'A' AND actual_start_date >= l_actual_date)
                      )
                 )
              OR p_delete_future_recurrences = 'A'
             )
         AND NVL(deleted_flag, 'N') = 'N'
         AND task_id <> p_task_id;

    CURSOR c_dependencies IS
      SELECT dependency_id
           , object_version_number
        FROM jtf_task_depends
       WHERE task_id = l_task_id OR dependent_on_task_id = l_task_id;

    CURSOR c_references IS
      SELECT task_reference_id
           , object_version_number
        FROM jtf_task_references_vl
       WHERE task_id = l_task_id;

    CURSOR c_dates IS
      SELECT task_date_id
           , object_version_number
        FROM jtf_task_dates
       WHERE task_id = l_task_id;

    CURSOR c_rsc_reqs IS
      SELECT resource_req_id
           , object_version_number
        FROM jtf_task_rsc_reqs
       WHERE task_id = l_task_id;

    CURSOR c_assignments IS
      SELECT task_assignment_id
           , object_version_number
        FROM jtf_task_all_assignments
       WHERE task_id = l_task_id;

    -- Added to fix Bug # 2503657
    CURSOR c_contacts IS
      SELECT task_contact_id
           , object_version_number
        FROM jtf_task_contacts
       WHERE task_id = l_task_id;

    -- Added to fix Bug # 2585935
    CURSOR c_contact_points IS
      SELECT a.object_version_number
           , a.task_phone_id
        FROM jtf_task_phones a, jtf_tasks_b c
       WHERE a.owner_table_name = 'JTF_TASKS_B'
         AND a.task_contact_id = c.task_id
         AND c.task_id = l_task_id;

    --BES enh 2391065
    l_task_rec_type                jtf_tasks_pvt.task_rec_type;
    x_event_return_status          VARCHAR2(100);

    CURSOR task_source_orig(b_task_id IN NUMBER) IS
      SELECT source_object_id
           , source_object_type_code
           , entity
        FROM jtf_tasks_b
       WHERE task_id = b_task_id;

    CURSOR c_parent_child(b_date_selected jtf_task_recur_rules.date_selected%TYPE) IS
      SELECT count(*) FROM
      (SELECT task_number
          from jtf_tasks_b
        where parent_task_id = p_task_id
        AND NVL(deleted_flag, 'N') = 'N'
      UNION ALL
      SELECT task_number
        FROM jtf_tasks_b
       WHERE recurrence_rule_id = l_recur_rule
         AND (
                 (
                      p_delete_future_recurrences = fnd_api.g_true
                  AND (

                          ---------------------------
                          ---- 'P' use planned date
                          ---- null (existing data)
                          ---- also use planned date
                          ---------------------------
                          (NVL(b_date_selected, 'P') = 'P' AND planned_start_date >= l_planned_date)
                       OR
                          ---------------------------
                          ---- 'S' use scheduled date
                          ---------------------------
                          (b_date_selected = 'S' AND scheduled_start_date >= l_scheduled_date)
                       OR
                          ---------------------------
                          ---- 'A' use actual date
                          ---------------------------
                          (b_date_selected = 'A' AND actual_start_date >= l_actual_date)
                      )
                 )
              OR p_delete_future_recurrences = 'A'
             )
         AND NVL(deleted_flag, 'N') = 'N'
         AND task_id <> p_task_id
	 AND exists ( select *
                       from jtf_tasks_b
                      where parent_task_id = task_id ) );

    l_orig_source_object_id        jtf_tasks_b.source_object_id%TYPE;
    l_orig_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_entity                       jtf_tasks_b.entity%TYPE;
  BEGIN
    SAVEPOINT delete_task_pvt;
    x_return_status                          := fnd_api.g_ret_sts_success;

    -- Added by lokumar for bug#6598081
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

   -- ------------------------------------------------------------------------
    -- Check that the user has the correct security privilege
    -- ------------------------------------------------------------------------
    jtf_task_utl.check_security_privilege(p_task_id => p_task_id, p_session => 'DELETE'
    , x_return_status              => x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


        -------------------------------------------------------------------
        ---------------------- Workflow Enhancement -----------------------
        -------------------------------------------------------------------
        -- !!! moved this code to before all the deletes so the data is !!!
        -- !!! complete when the WF is sent       !!!
        -------------------------------------------------------------------
    /* Moved the code to subscription ER# 2797666
        IF p_enable_workflow = jtf_task_utl.g_yes
        THEN
      IF JTF_Task_WF_Util.Do_Notification(l_task_id)
      THEN
      JTF_Task_WF_Util.Create_Notification(
          p_event  => 'DELETE_TASK',
          p_task_id      => l_task_id,
          p_abort_workflow => p_abort_workflow,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data
      );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      END IF; -- Check JTF_Task_WF_Util.Do_Notification
        END IF; -- Check p_enable_workflow
    */
        -------------------------------------------------------------------

    ---------------------------
    ---- get recurrence rule id
    ---------------------------
    OPEN c_recur_rule(p_task_id);

    FETCH c_recur_rule
     INTO l_recur_rule
        , l_planned_date
        , l_scheduled_date
        , l_actual_date;

    CLOSE c_recur_rule;

    ---------------------------
    ---- get date_selected from
    ---- the recurrence rule
    ---------------------------
    IF l_recur_rule IS NOT NULL THEN
      OPEN c_recur_date(l_recur_rule);

      FETCH c_recur_date
       INTO l_date_selected;

      IF c_recur_date%NOTFOUND THEN
        CLOSE c_recur_date;

        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE c_recur_date;
    END IF;

    OPEN c_parent_child(l_date_selected);
    FETCH c_parent_child into l_parent_child_count;

    IF l_parent_child_count>0 THEN
       fnd_message.set_name('JTF', 'JTF_TASK_DELETING_PARENT_CHILD');
       fnd_msg_pub.ADD;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;




    jtf_tasks_pub.p_task_user_hooks.task_id  := p_task_id;
    jtf_tasks_iuhk.delete_task_pre(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    FOR i IN c_delete_task(l_date_selected) LOOP
      l_task_id                  := i.task_id;
      l_obj_version              := i.object_version_number;
      l_source_object_type_code  := i.source_object_type_code;   -- For XP Sync, Story #58
      l_calendar_start_date      := i.calendar_start_date;   -- For XP Sync, Story #58

      ---------------------------
      ---- delete dependencies
      ---------------------------
      FOR a IN c_dependencies LOOP
        jtf_task_dependency_pub.delete_task_dependency
                                               (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => a.object_version_number
        , p_dependency_id              => a.dependency_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      ---------------------------
      ---- delete references. Changed the call from public to private as this
      ---- removes the additional overhead of calling private api through public.
      ---------------------------
      FOR b IN c_references LOOP
        jtf_task_references_pvt.delete_references
                                               (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => b.object_version_number
        , p_task_reference_id          => b.task_reference_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_from_task_api              => 'Y'
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      ---------------------------
      ---- delete dates
      ---------------------------
      FOR c IN c_dates LOOP
        jtf_task_dates_pub.delete_task_dates(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => c.object_version_number
        , p_task_date_id               => c.task_date_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      ---------------------------
      ---- delete resource reqs.
      ---------------------------
      FOR c IN c_rsc_reqs LOOP
        jtf_task_resources_pub.delete_task_rsrc_req
                                               (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => c.object_version_number
        , p_resource_req_id            => c.resource_req_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      ---------------------------------------------------------------
      -- For XP Sync Story #58
      --    When a user updates one of occurrences in Outlook/Palm,
      --   This deletes it and insert it into JTA_TASK_EXCLUSIONS
      --    When a user deletes one of occurrences in Server,
      --   This deletes it and insert it into JTA_TASK_EXCLUSIONS
      --    We support this only for Appointment
      --        and p_delete_future_recurrences <> 'A'
      --    If the deleted task is the first task of the series,
      --  then update task_id with the next min of task_id
      --   into mapping table
      -- Added 'EXTERNAL APPOINTMENT' to fix bug# 5255363 on 09/06/2006
      ---------------------------------------------------------------
      IF (
              (NVL(p_delete_future_recurrences, fnd_api.g_false) <> 'A')
          AND (l_recur_rule IS NOT NULL)
          AND (l_source_object_type_code IN('APPOINTMENT', 'EXTERNAL APPOINTMENT'))
         ) THEN
        SELECT jta_task_exclusions_s.NEXTVAL
          INTO l_task_exclusion_id
          FROM DUAL;

        jta_task_exclusions_pkg.insert_row(
          p_task_exclusion_id          => l_task_exclusion_id
        , p_task_id                    => l_task_id
        , p_recurrence_rule_id         => l_recur_rule
        , p_exclusion_date             => l_calendar_start_date
        );

        -- Modify task_id in the sync mapping table
        IF p_task_id = l_task_id THEN
          jta_sync_task_utl.update_mapping(p_task_id => p_task_id);
        END IF;
      END IF;

      ---------------------------------------------------------------

      ---------------------------
      ---- delete assignments
      ---------------------------
      FOR c IN c_assignments LOOP
        jtf_task_assignments_pvt.delete_task_assignment
                               (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => c.object_version_number
        , p_task_assignment_id         => c.task_assignment_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
        , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
        , p_delete_option              => jtf_task_repeat_appt_pvt.g_skip
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      jtf_tasks_pub.lock_task(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => l_task_id
      , p_object_version_number      => l_obj_version
      , x_return_status              => x_return_status
      , x_msg_data                   => x_msg_data
      , x_msg_count                  => x_msg_count
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      UPDATE jtf_tasks_b
         SET deleted_flag = 'Y'
           , last_update_date = SYSDATE
           , last_updated_by = fnd_global.user_id
           , object_changed_date = SYSDATE
       WHERE task_id = l_task_id;

      IF SQL%NOTFOUND THEN
        fnd_message.set_name('JTF', 'JTF_TASK_ERROR_DELETING_TASK');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --- Moving the business event code here to fix bug 3363174 ..
      --BES enh 2391065
      OPEN task_source_orig(l_task_id);

      FETCH task_source_orig
       INTO l_orig_source_object_id
          , l_orig_source_object_type_code
          , l_entity;

      IF task_source_orig%NOTFOUND THEN
        CLOSE task_source_orig;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE task_source_orig;

      IF (l_entity = 'TASK') THEN
        l_task_rec_type.task_id                  := l_task_id;
        l_task_rec_type.enable_workflow          := p_enable_workflow;
        l_task_rec_type.abort_workflow           := p_abort_workflow;
        l_task_rec_type.source_object_type_code  := l_orig_source_object_type_code;
        l_task_rec_type.source_object_id         := l_orig_source_object_id;
        jtf_task_wf_events_pvt.publish_delete_task(p_task_rec => l_task_rec_type
        , x_return_status              => x_event_return_status);

        IF (x_event_return_status = 'WARNING') THEN
          fnd_message.set_name('JTF', 'JTF_TASK_EVENT_WARNING');
          fnd_message.set_token('P_TASK_ID', l_task_id);
          fnd_msg_pub.ADD;
        ELSIF(x_event_return_status = 'ERROR') THEN
          fnd_message.set_name('JTF', 'JTF_TASK_EVENT_ERROR');
          fnd_message.set_token('P_TASK_ID', l_task_id);
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      --BES enh 2391065

      -- Added to fix Bug # 2503657
          ---------------------------
          ---- delete contacts
          ---------------------------
      FOR cc IN c_contacts LOOP
        jtf_task_contacts_pub.delete_task_contacts
                                              (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => cc.object_version_number
        , p_task_contact_id            => cc.task_contact_id
        , x_return_status              => x_return_status
        , x_msg_data                   => x_msg_data
        , x_msg_count                  => x_msg_count
        , p_delete_cascade             => jtf_task_utl.g_yes_char
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;   -- End of delete contacts

      -- Added to fix Bug # 2585935
          ----------------------------
          ------ delete contact points
          ----------------------------
      FOR cp IN c_contact_points LOOP
        jtf_task_phones_pub.delete_task_phones
                                              (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_object_version_number      => cp.object_version_number
        , p_task_phone_id              => cp.task_phone_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;   -- End of delete contact points
    END LOOP;   --- loop for the task;.

    jtf_tasks_iuhk.delete_task_post(x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------------------------------------------------------------------
    ---------------------- Workflow Enhancement -----------------------
    -------------------------------------------------------------------
    -- !!! moved this code to before all the deletes so the data is !!!
    -- !!! complete when the WF is sent       !!!
    -------------------------------------------------------------------
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_task_pvt;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_task_pvt;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE export_file(
    p_path          IN            VARCHAR2
  , p_file_name     IN            VARCHAR2
  , p_task_table    IN            jtf_tasks_pub.task_table_type
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    -- variables
    l_api_name     VARCHAR2(30)       := 'EXPORT_FILE';
    v_file         UTL_FILE.file_type;   -- output file handle
    v_start        NUMBER             := p_task_table.FIRST;
    v_end          NUMBER             := p_task_table.LAST;
    v_cnt          NUMBER;
    v_tab CONSTANT VARCHAR2(1)        := fnd_global.local_chr(9);   --tab value 9 in ascii

    PROCEDURE put_f_out(p_str IN VARCHAR2) IS
    BEGIN
      UTL_FILE.putf(v_file, p_str || v_tab);
    END put_f_out;

    PROCEDURE put_f(p_in IN VARCHAR2) IS
    BEGIN
      put_f_out(p_in);
    END put_f;

    PROCEDURE put_f(p_in IN NUMBER) IS
    BEGIN
      put_f_out(TO_CHAR(p_in));
    END put_f;

    PROCEDURE put_f(p_in IN DATE) IS
    BEGIN
      ---
      --- hbucksey 13-Feb-2002
      --- Replaced 'dd-mon-rrrr' format mask with 'dd-mm-rrrr' in order to ensure
      --- NLS compliance
      --- This is to resolve GSCC warning File.Sql.24
      ---   2688 - TO_DATE should not use month/day names
      ---
      put_f_out(TO_DATE(p_in, 'dd-mm-rrrr'));
    --  put_f_out (to_date(p_in, 'dd-mon-rrrr'));
    END put_f;
  BEGIN   -- export file
    x_return_status  := fnd_api.g_ret_sts_success;

    -- close file if its open
    IF (UTL_FILE.is_open(v_file)) THEN
      UTL_FILE.fclose(v_file);
    END IF;

    -- open file for write only
    v_file           := UTL_FILE.fopen(p_path, p_file_name, 'w');

    FOR v_cnt IN v_start .. v_end LOOP
      put_f(p_task_table(v_cnt).task_id);
      put_f(p_task_table(v_cnt).task_number);
      put_f(p_task_table(v_cnt).task_name);
      put_f(p_task_table(v_cnt).task_type);
      put_f(p_task_table(v_cnt).task_status);
      put_f(p_task_table(v_cnt).task_priority);
      put_f(p_task_table(v_cnt).planned_start_date);
      put_f(p_task_table(v_cnt).planned_end_date);
      put_f(p_task_table(v_cnt).actual_start_date);
      put_f(p_task_table(v_cnt).actual_end_date);
      put_f(p_task_table(v_cnt).scheduled_start_date);
      put_f(p_task_table(v_cnt).scheduled_end_date);
      put_f(p_task_table(v_cnt).DURATION);
      put_f(p_task_table(v_cnt).duration_uom);
      put_f(p_task_table(v_cnt).planned_effort);
      put_f(p_task_table(v_cnt).planned_effort_uom);
      UTL_FILE.new_line(v_file, 1);
    END LOOP;

    -- close file
    UTL_FILE.fclose(v_file);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (UTL_FILE.is_open(v_file)) THEN
        UTL_FILE.fclose(v_file);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (UTL_FILE.is_open(v_file)) THEN
        UTL_FILE.fclose(v_file);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (UTL_FILE.is_open(v_file)) THEN
        UTL_FILE.fclose(v_file);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END export_file;

  PROCEDURE dump_long_line(txt IN VARCHAR2, v_str IN VARCHAR2) IS
    LN INTEGER := LENGTH(v_str);
    st INTEGER := 1;
  BEGIN
    LOOP
      st  := st + 72;
      EXIT WHEN(st >= LN);
    END LOOP;
  END dump_long_line;

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
  ) IS
    -- declare variables
    l_api_name VARCHAR2(30) := 'QUERY_TASK';
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    query_task(
      p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_description                => p_description
    , p_task_type_id               => p_task_type_id
    , p_task_status_id             => p_task_status_id
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_assigned_by_id             => p_assigned_by_id
    , p_address_id                 => p_address_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_customer_id                => p_customer_id
    , p_cust_account_id            => p_cust_account_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_object_type_code           => p_object_type_code
    , p_source_object_id           => p_source_object_id
    , p_percentage_complete        => p_percentage_complete
    , p_reason_code                => p_reason_code
    , p_private_flag               => p_private_flag
    , p_restrict_closure_flag      => p_restrict_closure_flag
    , p_multi_booked_flag          => p_multi_booked_flag
    , p_milestone_flag             => p_milestone_flag
    , p_holiday_flag               => p_holiday_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_notification_flag          => p_notification_flag
    , p_parent_task_id             => p_parent_task_id
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_fired_count          => p_alarm_fired_count
    , p_ref_object_id              => p_ref_object_id
    , p_ref_object_type_code       => p_ref_object_type_code
    , p_task_name                  => p_task_name
    , p_sort_data                  => p_sort_data
    , p_start_pointer              => p_start_pointer
    , p_rec_wanted                 => p_rec_wanted
    , p_show_all                   => p_show_all
    , p_query_or_next_code         => p_query_or_next_code
    , x_task_table                 => x_task_table
    , x_total_retrieved            => x_total_retrieved
    , x_total_returned             => x_total_returned
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_location_id                => NULL
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_task;

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
  ) IS
    -- declare variables
    l_api_name  VARCHAR2(30)           := 'QUERY_TASK';
    v_cursor_id INTEGER;
    v_dummy     INTEGER;
    v_cnt       INTEGER;
    v_end       INTEGER;
    v_start     INTEGER;
    v_type      jtf_tasks_pub.task_rec;

    PROCEDURE create_sql_statement IS
      v_index INTEGER;
      v_first INTEGER;
      v_comma VARCHAR2(5);
      v_where VARCHAR2(2000);
      v_and   CHAR(1)        := 'N';

      PROCEDURE add_to_sql_str(
        p_in    VARCHAR2
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
        v_str VARCHAR2(10);
      BEGIN   -- add_to_sql
        IF (p_in IS NOT NULL) THEN
          IF (v_and = 'N') THEN
            v_str  := ' ';
            v_and  := 'Y';
          ELSE
            v_str  := ' and ';
          END IF;

          v_where  := v_where || v_str || p_field || ' = :' || p_bind;
        END IF;
      END add_to_sql_str;

      PROCEDURE add_to_sql(
        p_in    NUMBER
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(TO_CHAR(p_in), p_bind, p_field);
      END;

      PROCEDURE add_to_sql(
        p_in    DATE
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(TO_CHAR(p_in, 'dd-mon-rrrr'), p_bind, p_field);
      END;

      PROCEDURE add_to_sql(
        p_in    VARCHAR2
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(p_in, p_bind, p_field);
      END;
    BEGIN   --create_sql_statement
      v_select  :=
           'select '
        || 'task_id,'
        || 'task_number,'
        || 'task_name,'
        || 'description,'
        || 'task_type_id,'
        || 'task_type,'
        || 'task_status_id,'
        || 'task_status,'
        || 'task_priority_id,'
        || 'task_priority,'
        || 'owner_type_code,'
        || 'owner_id,'
        || 'assigned_by_id,'
        || 'assigned_by_name,'
        || 'customer_id,'
        || 'customer_name,'
        || 'customer_number,'
        || 'address_id,'
        || 'planned_start_date,'
        || 'planned_end_date,'
        || 'scheduled_start_date,'
        || 'scheduled_end_date,'
        || 'actual_start_date,'
        || 'actual_end_date,'
        || 'source_object_type_code,'
        || 'source_object_id,'
        || 'source_object_name,'
        || 'duration,'
        || 'duration_uom,'
        || 'planned_effort,'
        || 'planned_effort_uom,'
        || 'actual_effort,'
        || 'actual_effort_uom,'
        || 'percentage_complete,'
        || 'reason_code,'
        || 'private_flag,'
        || 'publish_flag,'
        || 'multi_booked_flag,'
        || 'milestone_flag,'
        || 'holiday_flag,'
        || 'workflow_process_id,'
        || 'notification_flag,'
        || 'notification_period,'
        || 'notification_period_uom,'
        || 'parent_task_id,'
        || 'alarm_start,'
        || 'alarm_start_uom,'
        || 'alarm_on,'
        || 'alarm_count,'
        || 'alarm_fired_count,'
        || 'alarm_interval,'
        || 'alarm_interval_uom,'
        || 'attribute1,'
        || 'attribute2,'
        || 'attribute3,'
        || 'attribute4,'
        || 'attribute5,'
        || 'attribute6,'
        || 'attribute7,'
        || 'attribute8,'
        || 'attribute9,'
        || 'attribute10,'
        || 'attribute11,'
        || 'attribute12,'
        || 'attribute13,'
        || 'attribute14,'
        || 'attribute15,'
        || 'attribute_category,'
        || 'owner,'
        || 'cust_account_number,'
        || 'cust_account_id,'
        || 'owner_territory_id,'
        || 'creation_date, '
        || 'escalation_level, '
        || 'object_version_number, '
        || 'location_id '
        || 'from jtf_tasks_v ';
      add_to_sql(p_task_id, 'b1', 'task_id');
      add_to_sql(p_description, 'b2', 'description');
      add_to_sql(p_task_status_id, 'b3', 'task_status_id');
      add_to_sql(p_task_priority_id, 'b4', 'task_priority_id');
      add_to_sql(p_owner_type_code, 'b5', 'owner_type_code');
      add_to_sql(p_owner_id, 'b6', 'owner_id');
      add_to_sql(p_assigned_by_id, 'b7', 'assigned_by_id');
      add_to_sql(p_address_id, 'b8', 'address_id');
      add_to_sql(p_planned_start_date, 'b9', 'planned_start_date');
      add_to_sql(p_planned_end_date, 'b10', 'planned_end_date');
      add_to_sql(p_scheduled_start_date, 'b11', 'scheduled_start_date');
      add_to_sql(p_scheduled_end_date, 'b12', 'scheduled_end_date');
      add_to_sql(p_actual_start_date, 'b13', 'actual_start_date');
      add_to_sql(p_actual_end_date, 'b14', 'actual_end_date');
      add_to_sql(p_object_type_code, 'b15', 'source_object_type_code');
      add_to_sql(p_percentage_complete, 'b16', 'percentage_complete');
      add_to_sql(p_reason_code, 'b17', 'reason_code');
      add_to_sql(p_private_flag, 'b18', 'private_flag');
      add_to_sql(p_restrict_closure_flag, 'b19', 'restrict_closure_flag');
      add_to_sql(p_multi_booked_flag, 'b20', 'multi_booked_flag');
      add_to_sql(p_milestone_flag, 'b21', 'milestone_flag');
      add_to_sql(p_holiday_flag, 'b22', 'holiday_flag');
      add_to_sql(p_workflow_process_id, 'b23', 'workflow_process_id');
      add_to_sql(p_notification_flag, 'b27', 'notification_flag');
      add_to_sql(p_parent_task_id, 'b28', 'parent_task_id');
      add_to_sql(p_alarm_on, 'b29', 'alarm_on');
      add_to_sql(p_alarm_count, 'b30', 'alarm_count');
      add_to_sql(p_alarm_fired_count, 'b31', 'alarm_fired_count');
      add_to_sql(p_task_name, 'b32', 'task_name');
      add_to_sql(p_owner_territory_id, 'b33', 'owner_territory_id');
      add_to_sql(p_customer_id, 'b34', 'customer_id');
      add_to_sql(p_cust_account_id, 'b35', 'cust_account_id');
      add_to_sql(p_task_type_id, 'b36', 'task_type_id');
      add_to_sql(p_source_object_id, 'b37', 'source_object_id');
      add_to_sql(p_location_id, 'b38', 'location_id');

      -- jtf_task_references table if object code given
      IF (p_ref_object_type_code IS NOT NULL) AND(p_ref_object_id IS NOT NULL) THEN
        IF (v_where IS NOT NULL) THEN
          v_where  := v_where || ' and';
        END IF;

        v_where  :=
             v_where
          || ' exists '
          || '(select * from jtf_task_references_vl r '
          || '  where r.task_id = jtf_tasks_v.task_id '
          || '	 and r.object_id = :b100 '
          || '	 and r.object_type_code = :b101 ) ';
      END IF;

      IF (v_where IS NOT NULL) THEN
        v_select  := v_select || ' where ' || v_where;
      END IF;

      IF (p_sort_data.COUNT > 0) THEN   --there is a sort preference
        v_select  := v_select || ' order by ';
        v_index   := p_sort_data.FIRST;
        v_first   := v_index;

        LOOP
          IF (v_first = v_index) THEN
            v_comma  := ' ';
          ELSE
            v_comma  := ', ';
          END IF;

          v_select  := v_select || v_comma || p_sort_data(v_index).field_name || ' ';

          -- ascending or descending order
          IF (p_sort_data(v_index).asc_dsc_flag = 'A') THEN
            v_select  := v_select || 'asc ';
          ELSIF(p_sort_data(v_index).asc_dsc_flag = 'D') THEN
            v_select  := v_select || 'desc ';
          END IF;

          EXIT WHEN v_index = p_sort_data.LAST;
          v_index   := p_sort_data.NEXT(v_index);
        END LOOP;
      END IF;
    END create_sql_statement;
  BEGIN   -- query task
    x_return_status    := fnd_api.g_ret_sts_success;
    x_task_table.DELETE;

    IF (p_query_or_next_code = 'Q') THEN
      v_tbl.DELETE;
      create_sql_statement;
      --dump_long_line('v_sel:',v_select);
      v_cursor_id  := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor_id, v_select, DBMS_SQL.v7);

      -- bind variables only if they added to the sql statement
      IF (p_task_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b1', p_task_id);
      END IF;

      IF (p_description IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b2', p_description);
      END IF;

      IF (p_task_status_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b3', p_task_status_id);
      END IF;

      IF (p_task_priority_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b4', p_task_priority_id);
      END IF;

      IF (p_owner_type_code IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b5', p_owner_type_code);
      END IF;

      IF (p_owner_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b6', p_owner_id);
      END IF;

      IF (p_assigned_by_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b7', p_assigned_by_id);
      END IF;

      IF (p_address_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b8', p_address_id);
      END IF;

      IF (p_planned_start_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b9', p_planned_start_date);
      END IF;

      IF (p_planned_end_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b10', p_planned_end_date);
      END IF;

      IF (p_scheduled_start_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b11', p_scheduled_start_date);
      END IF;

      IF (p_scheduled_end_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b12', p_scheduled_end_date);
      END IF;

      IF (p_actual_start_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b13', p_actual_start_date);
      END IF;

      IF (p_actual_end_date IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b14', p_actual_end_date);
      END IF;

      IF (p_object_type_code IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b15', p_object_type_code);
      END IF;

      IF (p_percentage_complete IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b16', p_percentage_complete);
      END IF;

      IF (p_reason_code IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b17', p_reason_code);
      END IF;

      IF (p_private_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b18', p_private_flag);
      END IF;

      IF (p_restrict_closure_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b19', p_restrict_closure_flag);
      END IF;

      IF (p_multi_booked_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b20', p_multi_booked_flag);
      END IF;

      IF (p_milestone_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b21', p_milestone_flag);
      END IF;

      IF (p_holiday_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b22', p_holiday_flag);
      END IF;

      IF (p_workflow_process_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b23', p_workflow_process_id);
      END IF;

      IF (p_notification_flag IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b27', p_notification_flag);
      END IF;

      IF (p_parent_task_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b28', p_parent_task_id);
      END IF;

      IF (p_alarm_on IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b29', p_alarm_on);
      END IF;

      IF (p_alarm_count IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b30', p_alarm_count);
      END IF;

      IF (p_alarm_fired_count IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b31', p_alarm_fired_count);
      END IF;

      IF (p_task_name IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b32', p_task_name);
      END IF;

      IF (p_owner_territory_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b33', p_owner_territory_id);
      END IF;

      IF (p_customer_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b34', p_customer_id);
      END IF;

      IF (p_cust_account_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b35', p_cust_account_id);
      END IF;

      IF (p_task_type_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b36', p_task_type_id);
      END IF;

      IF (p_source_object_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b37', p_source_object_id);
      END IF;

      IF (p_location_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b38', p_location_id);
      END IF;

      IF (p_ref_object_type_code IS NOT NULL) AND(p_ref_object_id IS NOT NULL) THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b100', p_ref_object_id);
        DBMS_SQL.bind_variable(v_cursor_id, ':b101', p_ref_object_type_code);
      END IF;

      -- define the output columns
      DBMS_SQL.define_column(v_cursor_id, 1, v_type.task_id);
      DBMS_SQL.define_column(v_cursor_id, 2, v_type.task_number, 30);
      DBMS_SQL.define_column(v_cursor_id, 3, v_type.task_name, 80);
      DBMS_SQL.define_column(v_cursor_id, 4, v_type.description, 4000);
      DBMS_SQL.define_column(v_cursor_id, 5, v_type.task_type_id);
      DBMS_SQL.define_column(v_cursor_id, 6, v_type.task_type, 30);
      DBMS_SQL.define_column(v_cursor_id, 7, v_type.task_status_id);
      DBMS_SQL.define_column(v_cursor_id, 8, v_type.task_status, 30);
      DBMS_SQL.define_column(v_cursor_id, 9, v_type.task_priority_id);
      DBMS_SQL.define_column(v_cursor_id, 10, v_type.task_priority, 30);
      DBMS_SQL.define_column(v_cursor_id, 11, v_type.owner_type_code, 20);
      DBMS_SQL.define_column(v_cursor_id, 12, v_type.owner_id);
      DBMS_SQL.define_column(v_cursor_id, 13, v_type.assigned_by_id);
      DBMS_SQL.define_column(v_cursor_id, 14, v_type.assigned_by_name, 100);
      DBMS_SQL.define_column(v_cursor_id, 15, v_type.customer_id);
      DBMS_SQL.define_column(v_cursor_id, 16, v_type.customer_name, 255);
      DBMS_SQL.define_column(v_cursor_id, 17, v_type.customer_number, 30);
      DBMS_SQL.define_column(v_cursor_id, 18, v_type.address_id);
      DBMS_SQL.define_column(v_cursor_id, 19, v_type.planned_start_date);
      DBMS_SQL.define_column(v_cursor_id, 20, v_type.planned_end_date);
      DBMS_SQL.define_column(v_cursor_id, 21, v_type.scheduled_start_date);
      DBMS_SQL.define_column(v_cursor_id, 22, v_type.scheduled_end_date);
      DBMS_SQL.define_column(v_cursor_id, 23, v_type.actual_start_date);
      DBMS_SQL.define_column(v_cursor_id, 24, v_type.actual_end_date);
      DBMS_SQL.define_column(v_cursor_id, 25, v_type.object_type_code, 30);
      DBMS_SQL.define_column(v_cursor_id, 26, v_type.object_id);
      DBMS_SQL.define_column(v_cursor_id, 27, v_type.obect_name, 30);
      DBMS_SQL.define_column(v_cursor_id, 28, v_type.DURATION);
      DBMS_SQL.define_column(v_cursor_id, 29, v_type.duration_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 30, v_type.planned_effort);
      DBMS_SQL.define_column(v_cursor_id, 31, v_type.planned_effort_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 32, v_type.actual_effort);
      DBMS_SQL.define_column(v_cursor_id, 33, v_type.actual_effort_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 34, v_type.percentage_complete);
      DBMS_SQL.define_column(v_cursor_id, 35, v_type.reason_code, 30);
      DBMS_SQL.define_column(v_cursor_id, 36, v_type.private_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 37, v_type.publish_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 38, v_type.multi_booked_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 39, v_type.milestone_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 40, v_type.holiday_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 41, v_type.workflow_process_id);
      DBMS_SQL.define_column(v_cursor_id, 42, v_type.notification_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 43, v_type.notification_period);
      DBMS_SQL.define_column(v_cursor_id, 44, v_type.notification_period_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 45, v_type.parent_task_id);
      DBMS_SQL.define_column(v_cursor_id, 46, v_type.alarm_start);
      DBMS_SQL.define_column(v_cursor_id, 47, v_type.alarm_start_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 48, v_type.alarm_on, 1);
      DBMS_SQL.define_column(v_cursor_id, 49, v_type.alarm_count);
      DBMS_SQL.define_column(v_cursor_id, 50, v_type.alarm_fired_count);
      DBMS_SQL.define_column(v_cursor_id, 51, v_type.alarm_interval);
      DBMS_SQL.define_column(v_cursor_id, 52, v_type.alarm_interval_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 53, v_type.attribute1, 150);
      DBMS_SQL.define_column(v_cursor_id, 54, v_type.attribute2, 150);
      DBMS_SQL.define_column(v_cursor_id, 55, v_type.attribute3, 150);
      DBMS_SQL.define_column(v_cursor_id, 56, v_type.attribute4, 150);
      DBMS_SQL.define_column(v_cursor_id, 57, v_type.attribute5, 150);
      DBMS_SQL.define_column(v_cursor_id, 58, v_type.attribute6, 150);
      DBMS_SQL.define_column(v_cursor_id, 59, v_type.attribute7, 150);
      DBMS_SQL.define_column(v_cursor_id, 60, v_type.attribute8, 150);
      DBMS_SQL.define_column(v_cursor_id, 61, v_type.attribute9, 150);
      DBMS_SQL.define_column(v_cursor_id, 62, v_type.attribute10, 150);
      DBMS_SQL.define_column(v_cursor_id, 63, v_type.attribute11, 150);
      DBMS_SQL.define_column(v_cursor_id, 64, v_type.attribute12, 150);
      DBMS_SQL.define_column(v_cursor_id, 65, v_type.attribute13, 150);
      DBMS_SQL.define_column(v_cursor_id, 66, v_type.attribute14, 150);
      DBMS_SQL.define_column(v_cursor_id, 67, v_type.attribute15, 150);
      DBMS_SQL.define_column(v_cursor_id, 68, v_type.attribute_category, 150);
      DBMS_SQL.define_column(v_cursor_id, 69, v_type.owner, 100);
      DBMS_SQL.define_column(v_cursor_id, 70, v_type.cust_account_number, 30);
      DBMS_SQL.define_column(v_cursor_id, 71, v_type.cust_account_id);
      DBMS_SQL.define_column(v_cursor_id, 72, v_type.owner_territory_id);
      DBMS_SQL.define_column(v_cursor_id, 73, v_type.creation_date);
      DBMS_SQL.define_column(v_cursor_id, 74, v_type.escalation_level, 30);
      DBMS_SQL.define_column(v_cursor_id, 75, v_type.object_version_number);
      DBMS_SQL.define_column(v_cursor_id, 76, v_type.location_id);
      v_dummy      := DBMS_SQL.EXECUTE(v_cursor_id);
      v_cnt        := 0;

      LOOP
        EXIT WHEN(DBMS_SQL.fetch_rows(v_cursor_id) = 0);
        v_cnt         := v_cnt + 1;
        -- retrieve the rows from the buffer
        DBMS_SQL.column_value(v_cursor_id, 1, v_type.task_id);
        DBMS_SQL.column_value(v_cursor_id, 2, v_type.task_number);
        DBMS_SQL.column_value(v_cursor_id, 3, v_type.task_name);
        DBMS_SQL.column_value(v_cursor_id, 4, v_type.description);
        DBMS_SQL.column_value(v_cursor_id, 5, v_type.task_type_id);
        DBMS_SQL.column_value(v_cursor_id, 6, v_type.task_type);
        DBMS_SQL.column_value(v_cursor_id, 7, v_type.task_status_id);
        DBMS_SQL.column_value(v_cursor_id, 8, v_type.task_status);
        DBMS_SQL.column_value(v_cursor_id, 9, v_type.task_priority_id);
        DBMS_SQL.column_value(v_cursor_id, 10, v_type.task_priority);
        DBMS_SQL.column_value(v_cursor_id, 11, v_type.owner_type_code);
        DBMS_SQL.column_value(v_cursor_id, 12, v_type.owner_id);
        DBMS_SQL.column_value(v_cursor_id, 13, v_type.assigned_by_id);
        DBMS_SQL.column_value(v_cursor_id, 14, v_type.assigned_by_name);
        DBMS_SQL.column_value(v_cursor_id, 15, v_type.customer_id);
        DBMS_SQL.column_value(v_cursor_id, 16, v_type.customer_name);
        DBMS_SQL.column_value(v_cursor_id, 17, v_type.customer_number);
        DBMS_SQL.column_value(v_cursor_id, 18, v_type.address_id);
        DBMS_SQL.column_value(v_cursor_id, 19, v_type.planned_start_date);
        DBMS_SQL.column_value(v_cursor_id, 20, v_type.planned_end_date);
        DBMS_SQL.column_value(v_cursor_id, 21, v_type.scheduled_start_date);
        DBMS_SQL.column_value(v_cursor_id, 22, v_type.scheduled_end_date);
        DBMS_SQL.column_value(v_cursor_id, 23, v_type.actual_start_date);
        DBMS_SQL.column_value(v_cursor_id, 24, v_type.actual_end_date);
        DBMS_SQL.column_value(v_cursor_id, 25, v_type.object_type_code);
        DBMS_SQL.column_value(v_cursor_id, 26, v_type.object_id);
        DBMS_SQL.column_value(v_cursor_id, 27, v_type.obect_name);
        DBMS_SQL.column_value(v_cursor_id, 28, v_type.DURATION);
        DBMS_SQL.column_value(v_cursor_id, 29, v_type.duration_uom);
        DBMS_SQL.column_value(v_cursor_id, 30, v_type.planned_effort);
        DBMS_SQL.column_value(v_cursor_id, 31, v_type.planned_effort_uom);
        DBMS_SQL.column_value(v_cursor_id, 32, v_type.actual_effort);
        DBMS_SQL.column_value(v_cursor_id, 33, v_type.actual_effort_uom);
        DBMS_SQL.column_value(v_cursor_id, 34, v_type.percentage_complete);
        DBMS_SQL.column_value(v_cursor_id, 35, v_type.reason_code);
        DBMS_SQL.column_value(v_cursor_id, 36, v_type.private_flag);
        DBMS_SQL.column_value(v_cursor_id, 37, v_type.publish_flag);
        DBMS_SQL.column_value(v_cursor_id, 38, v_type.multi_booked_flag);
        DBMS_SQL.column_value(v_cursor_id, 39, v_type.milestone_flag);
        DBMS_SQL.column_value(v_cursor_id, 40, v_type.holiday_flag);
        DBMS_SQL.column_value(v_cursor_id, 41, v_type.workflow_process_id);
        DBMS_SQL.column_value(v_cursor_id, 42, v_type.notification_flag);
        DBMS_SQL.column_value(v_cursor_id, 43, v_type.notification_period);
        DBMS_SQL.column_value(v_cursor_id, 44, v_type.notification_period_uom);
        DBMS_SQL.column_value(v_cursor_id, 45, v_type.parent_task_id);
        DBMS_SQL.column_value(v_cursor_id, 46, v_type.alarm_start);
        DBMS_SQL.column_value(v_cursor_id, 47, v_type.alarm_start_uom);
        DBMS_SQL.column_value(v_cursor_id, 48, v_type.alarm_on);
        DBMS_SQL.column_value(v_cursor_id, 49, v_type.alarm_count);
        DBMS_SQL.column_value(v_cursor_id, 50, v_type.alarm_fired_count);
        DBMS_SQL.column_value(v_cursor_id, 51, v_type.alarm_interval);
        DBMS_SQL.column_value(v_cursor_id, 52, v_type.alarm_interval_uom);
        DBMS_SQL.column_value(v_cursor_id, 53, v_type.attribute1);
        DBMS_SQL.column_value(v_cursor_id, 54, v_type.attribute2);
        DBMS_SQL.column_value(v_cursor_id, 55, v_type.attribute3);
        DBMS_SQL.column_value(v_cursor_id, 56, v_type.attribute4);
        DBMS_SQL.column_value(v_cursor_id, 57, v_type.attribute5);
        DBMS_SQL.column_value(v_cursor_id, 58, v_type.attribute6);
        DBMS_SQL.column_value(v_cursor_id, 59, v_type.attribute7);
        DBMS_SQL.column_value(v_cursor_id, 60, v_type.attribute8);
        DBMS_SQL.column_value(v_cursor_id, 61, v_type.attribute9);
        DBMS_SQL.column_value(v_cursor_id, 62, v_type.attribute10);
        DBMS_SQL.column_value(v_cursor_id, 63, v_type.attribute11);
        DBMS_SQL.column_value(v_cursor_id, 64, v_type.attribute12);
        DBMS_SQL.column_value(v_cursor_id, 65, v_type.attribute13);
        DBMS_SQL.column_value(v_cursor_id, 66, v_type.attribute14);
        DBMS_SQL.column_value(v_cursor_id, 67, v_type.attribute15);
        DBMS_SQL.column_value(v_cursor_id, 68, v_type.attribute_category);
        DBMS_SQL.column_value(v_cursor_id, 69, v_type.owner);
        DBMS_SQL.column_value(v_cursor_id, 70, v_type.cust_account_number);
        DBMS_SQL.column_value(v_cursor_id, 71, v_type.cust_account_id);
        DBMS_SQL.column_value(v_cursor_id, 72, v_type.owner_territory_id);
        DBMS_SQL.column_value(v_cursor_id, 73, v_type.creation_date);
        DBMS_SQL.column_value(v_cursor_id, 74, v_type.escalation_level);
        DBMS_SQL.column_value(v_cursor_id, 75, v_type.object_version_number);
        DBMS_SQL.column_value(v_cursor_id, 76, v_type.location_id);
        --      'v_type.task_id:'||
        --       to_char(v_type.task_id));
        v_tbl(v_cnt)  := v_type;
      END LOOP;

      DBMS_SQL.close_cursor(v_cursor_id);
    END IF;   --p_query_or_next_code;

    -- copy records to be returned back
    x_total_retrieved  := v_tbl.COUNT;

    -- if table is empty do nothing
    IF (x_total_retrieved > 0) THEN
      IF (p_show_all = 'Y') THEN   -- return all the rows
        v_start  := v_tbl.FIRST;
        v_end    := v_tbl.LAST;
      ELSE
        v_start  := p_start_pointer;
        v_end    := p_start_pointer + p_rec_wanted - 1;

        IF (v_end > v_tbl.LAST) THEN
          v_end  := v_tbl.LAST;
        END IF;
      END IF;

      FOR v_cnt IN v_start .. v_end LOOP
        x_task_table(v_cnt)  := v_tbl(v_cnt);
      END LOOP;
    END IF;

    x_total_returned   := x_task_table.COUNT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_task;

  PROCEDURE query_next_task(
    p_object_version_number IN            NUMBER
  , p_task_id               IN            jtf_tasks_v.task_id%TYPE
  ,   -- current task id
    p_query_type            IN            VARCHAR2 DEFAULT 'Dependency'
  ,   -- values Dependency or Date
    p_date_type             IN            VARCHAR2 DEFAULT NULL
  , p_date_start_or_end     IN            VARCHAR2 DEFAULT NULL
  ,   -- start or end
    p_owner_id              IN            jtf_tasks_v.owner_id%TYPE DEFAULT NULL
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
  ) IS
    -- declare variables
    l_api_name  VARCHAR2(30)           := 'QUERY_NEXT_TASK';
    v_cursor_id INTEGER;
    v_dummy     INTEGER;
    v_cnt       INTEGER;
    v_end       INTEGER;
    v_start     INTEGER;
    v_key_date  DATE;   -- stores date for query string
    v_find_date DATE;
    v_type      jtf_tasks_pub.task_rec;

    PROCEDURE create_sql_statement IS
      v_index       INTEGER;
      v_first       INTEGER;
      v_comma       VARCHAR2(5);
      v_where       VARCHAR2(2000);
      v_and         CHAR(1)        := 'N';
      v_date_sql    VARCHAR2(500);
      -- build the date field we are going to key on
      v_select_date VARCHAR2(50)   := UPPER(p_date_type || '_' || p_date_start_or_end || '_date');
      -- build the date field for the sub-query, always a 'start'
      v_start_date  VARCHAR2(50)   := UPPER(p_date_type || '_start_date');

      PROCEDURE add_to_sql_str(
        p_in    VARCHAR2
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
        v_str VARCHAR2(10);
      BEGIN   -- add_to_sql
        IF (p_in IS NOT NULL) THEN
          IF (v_and = 'N') THEN
            v_str  := ' ';
            v_and  := 'Y';
          ELSE
            v_str  := ' and ';
          END IF;

          v_where  := v_where || v_str || p_field || ' = :' || p_bind;
        END IF;
      END add_to_sql_str;

      PROCEDURE add_to_sql(
        p_in    NUMBER
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(TO_CHAR(p_in), p_bind, p_field);
      END;

      PROCEDURE add_to_sql(
        p_in    DATE
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(TO_CHAR(p_in, 'dd-mon-rrrr'), p_bind, p_field);
      END;

      PROCEDURE add_to_sql(
        p_in    VARCHAR2
      ,   --value in parameter
        p_bind  VARCHAR2
      ,   --bind variable to use
        p_field VARCHAR2   --field associated with parameter
      ) IS
      BEGIN
        add_to_sql_str(p_in, p_bind, p_field);
      END;

      FUNCTION get_date(p_date_field IN VARCHAR2, p_task_id IN NUMBER)
        RETURN DATE IS
          -- Commented out by SBARAT on 30/05/2006 for perf bug# 5213367
          /*cursor c_get_date is
            select decode (p_date_field,
             'PLANNED_START_DATE', planned_start_date,
             'PLANNED_END_DATE', planned_end_date,
             'SCHEDULED_START_DATE', scheduled_start_date,
             'SCHEDULED_END_DATE', scheduled_end_date,
             'ACTUAL_START_DATE', actual_start_date,
             'ACTUAL_END_DATE', actual_end_date, null)
        from jtf_tasks_v
        where task_id = p_task_id;*/

        -- Added by SBARAT on 30/05/2006 for perf bug# 5213367
        -- This query takea less sharable memory compared to previous one.
        CURSOR c_get_date IS
          SELECT DECODE(
                   p_date_field
                 , 'PLANNED_START_DATE', planned_start_date
                 , 'PLANNED_END_DATE', planned_end_date
                 , 'SCHEDULED_START_DATE', scheduled_start_date
                 , 'SCHEDULED_END_DATE', scheduled_end_date
                 , 'ACTUAL_START_DATE', actual_start_date
                 , 'ACTUAL_END_DATE', actual_end_date
                 , NULL
                 )
            FROM jtf_tasks_vl jta
               , jtf_task_types_tl jttt
               , jtf_task_types_b jttb
               , jtf_task_statuses_tl jtst
               , jtf_task_statuses_b jtsb
               , jtf_task_priorities_tl jtpt
               , jtf_objects_tl jtot
               , jtf_objects_b jtob
               , jtf_objects_tl jto2
           WHERE jta.task_id = p_task_id
             AND jta.task_type_id = jttb.task_type_id
             AND jta.task_status_id = jtsb.task_status_id
             AND (jta.deleted_flag <> 'Y' OR jta.deleted_flag IS NULL)
             AND jta.task_priority_id = jtpt.task_priority_id(+)
             AND jta.source_object_type_code = jtob.object_code
             AND jta.owner_type_code = jto2.object_code
             AND jttb.task_type_id <> 22
             AND NVL(jtpt.LANGUAGE, USERENV('lang')) = USERENV('lang')
             AND jttt.LANGUAGE = USERENV('lang')
             AND jttt.task_type_id = jta.task_type_id
             AND jtst.LANGUAGE = USERENV('lang')
             AND jtst.task_status_id = jta.task_status_id
             AND jtot.LANGUAGE = USERENV('lang')
             AND jtot.object_code = jtob.object_code
             AND jto2.LANGUAGE = USERENV('lang');

        v_return_date DATE;
      BEGIN
        OPEN c_get_date;

        FETCH c_get_date
         INTO v_return_date;

        IF (c_get_date%NOTFOUND) THEN
          CLOSE c_get_date;

          fnd_message.set_name('JTF', 'JTF_TK_NO_DATE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          CLOSE c_get_date;
        END IF;

        RETURN(v_return_date);
      END get_date;
    BEGIN   --create_sql_statement
      v_select  :=
           'select '
        || 'v.task_id,'
        || 'v.task_number,'
        || 'v.task_name,'
        || 'v.description,'
        || 'v.task_type_id,'
        || 'v.task_type,'
        || 'v.task_status_id,'
        || 'v.task_status,'
        || 'v.task_priority_id,'
        || 'v.task_priority,'
        || 'v.owner_type_code,'
        || 'v.owner_id,'
        || 'v.assigned_by_id,'
        || 'v.assigned_by_name,'
        || 'v.customer_id,'
        || 'v.customer_name,'
        || 'v.customer_number,'
        || 'v.address_id,'
        || 'v.planned_start_date,'
        || 'v.planned_end_date,'
        || 'v.scheduled_start_date,'
        || 'v.scheduled_end_date,'
        || 'v.actual_start_date,'
        || 'v.actual_end_date,'
        || 'v.source_object_type_code,'
        || 'v.source_object_id,'
        || 'v.source_object_name,'
        || 'v.duration,'
        || 'v.duration_uom,'
        || 'v.planned_effort,'
        || 'v.planned_effort_uom,'
        || 'v.actual_effort,'
        || 'v.actual_effort_uom,'
        || 'v.percentage_complete,'
        || 'v.reason_code,'
        || 'v.private_flag,'
        || 'v.publish_flag,'
        || 'v.multi_booked_flag,'
        || 'v.milestone_flag,'
        || 'v.holiday_flag,'
        || 'v.workflow_process_id,'
        || 'v.notification_flag,'
        || 'v.notification_period,'
        || 'v.notification_period_uom,'
        || 'v.parent_task_id,'
        || 'v.alarm_start,'
        || 'v.alarm_start_uom,'
        || 'v.alarm_on,'
        || 'v.alarm_count,'
        || 'v.alarm_fired_count,'
        || 'v.alarm_interval,'
        || 'v.alarm_interval_uom,'
        || 'v.attribute1,'
        || 'v.attribute2,'
        || 'v.attribute3,'
        || 'v.attribute4,'
        || 'v.attribute5,'
        || 'v.attribute6,'
        || 'v.attribute7,'
        || 'v.attribute8,'
        || 'v.attribute9,'
        || 'v.attribute10,'
        || 'v.attribute11,'
        || 'v.attribute12,'
        || 'v.attribute13,'
        || 'v.attribute14,'
        || 'v.attribute15,'
        || 'v.attribute_category '
        || 'from jtf_tasks_v v ';

      IF (p_query_type = 'DEPENDENCY') THEN
        v_select  := v_select || ', jtf_task_depends d ';
        add_to_sql(p_task_id, 'b1', 'd.dependent_on_task_id');

        IF (v_where IS NOT NULL) THEN
          v_select  := v_select || ' where v.task_id = d.task_id and ' || v_where;
        END IF;
      ELSE   -- must be assigned or owner
        v_key_date  := get_date(v_select_date, p_task_id);

        IF (p_query_type = 'ASSIGNED') THEN
          v_date_sql  :=
               'select min('
            || v_start_date
            || ') from jtf_tasks_v where assigned_by_id = '
            || TO_CHAR(p_assigned_by)
            || ' and '
            || v_start_date
            || ' > :1 ';

          EXECUTE IMMEDIATE v_date_sql
                       INTO v_find_date
                      USING v_key_date;

          add_to_sql(p_assigned_by, 'b10', 'assigned_by_id');
          v_where     := v_where || ' and ' || v_start_date || ' = :b11 ';
        ELSIF(p_query_type = 'OWNER') THEN
          v_date_sql  :=
               'select min('
            || v_start_date
            || ') from jtf_tasks_v where owner_type_code = '''
            || p_owner_type_code
            || ''' and '
            || 'owner_id = '
            || TO_CHAR(p_owner_id)
            || ' and '
            || v_start_date
            || ' > :1 ';

          EXECUTE IMMEDIATE v_date_sql
                       INTO v_find_date
                      USING v_key_date;

          add_to_sql(p_owner_type_code, 'b100', 'owner_type_code');
          add_to_sql(p_owner_id, 'b101', 'owner_id');
          v_where     := v_where || ' and ' || v_start_date || ' = :b102 ';
        END IF;

        IF (v_where IS NOT NULL) THEN
          v_select  := v_select || ' where ' || v_where;
        END IF;
      END IF;

      IF (p_sort_data.COUNT > 0) THEN   --there is a sort preference
        v_select  := v_select || ' order by ';
        v_index   := p_sort_data.FIRST;
        v_first   := v_index;

        LOOP
          IF (v_first = v_index) THEN
            v_comma  := ' ';
          ELSE
            v_comma  := ', ';
          END IF;

          v_select  := v_select || v_comma || p_sort_data(v_index).field_name || ' ';

          -- ascending or descending order
          IF (p_sort_data(v_index).asc_dsc_flag = 'A') THEN
            v_select  := v_select || 'asc ';
          ELSIF(p_sort_data(v_index).asc_dsc_flag = 'D') THEN
            v_select  := v_select || 'desc ';
          END IF;

          EXIT WHEN v_index = p_sort_data.LAST;
          v_index   := p_sort_data.NEXT(v_index);
        END LOOP;
      END IF;
    END create_sql_statement;
  BEGIN   -- query task
    x_return_status    := fnd_api.g_ret_sts_success;
    x_task_table.DELETE;

    IF (p_query_or_next_code = 'Q') THEN
      v_n_tbl.DELETE;
      create_sql_statement;
      --dump_long_line('v_sel:',v_select);
      v_cursor_id  := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor_id, v_select, DBMS_SQL.v7);

      -- bind variables only if they added to the sql statement
      IF (p_query_type = 'DEPENDENCY') THEN
        IF (p_task_id IS NOT NULL) THEN
          DBMS_SQL.bind_variable(v_cursor_id, ':b1', p_task_id);
        END IF;
      ELSIF(p_query_type = 'ASSIGNED') THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b10', p_assigned_by);
        DBMS_SQL.bind_variable(v_cursor_id, ':b11', v_find_date);
      ELSIF(p_query_type = 'OWNER') THEN
        DBMS_SQL.bind_variable(v_cursor_id, ':b100', p_owner_type_code);
        DBMS_SQL.bind_variable(v_cursor_id, ':b101', p_owner_id);
        DBMS_SQL.bind_variable(v_cursor_id, ':b102', v_find_date);
      END IF;

      -- define the output columns
      DBMS_SQL.define_column(v_cursor_id, 1, v_type.task_id);
      DBMS_SQL.define_column(v_cursor_id, 2, v_type.task_number, 30);
      DBMS_SQL.define_column(v_cursor_id, 3, v_type.task_name, 80);
      DBMS_SQL.define_column(v_cursor_id, 4, v_type.description, 4000);
      DBMS_SQL.define_column(v_cursor_id, 5, v_type.task_type_id);
      DBMS_SQL.define_column(v_cursor_id, 6, v_type.task_type, 30);
      DBMS_SQL.define_column(v_cursor_id, 7, v_type.task_status_id);
      DBMS_SQL.define_column(v_cursor_id, 8, v_type.task_status, 30);
      DBMS_SQL.define_column(v_cursor_id, 9, v_type.task_priority_id);
      DBMS_SQL.define_column(v_cursor_id, 10, v_type.task_priority, 30);
      DBMS_SQL.define_column(v_cursor_id, 11, v_type.owner_type_code, 10);
      DBMS_SQL.define_column(v_cursor_id, 12, v_type.owner_id);
      DBMS_SQL.define_column(v_cursor_id, 13, v_type.assigned_by_id);
      DBMS_SQL.define_column(v_cursor_id, 14, v_type.assigned_by_name, 100);
      DBMS_SQL.define_column(v_cursor_id, 15, v_type.customer_id);
      DBMS_SQL.define_column(v_cursor_id, 16, v_type.customer_name, 255);
      DBMS_SQL.define_column(v_cursor_id, 17, v_type.customer_number, 30);
      DBMS_SQL.define_column(v_cursor_id, 18, v_type.address_id);
      DBMS_SQL.define_column(v_cursor_id, 19, v_type.planned_start_date);
      DBMS_SQL.define_column(v_cursor_id, 20, v_type.planned_end_date);
      DBMS_SQL.define_column(v_cursor_id, 21, v_type.scheduled_start_date);
      DBMS_SQL.define_column(v_cursor_id, 22, v_type.scheduled_end_date);
      DBMS_SQL.define_column(v_cursor_id, 23, v_type.actual_start_date);
      DBMS_SQL.define_column(v_cursor_id, 24, v_type.actual_end_date);
      DBMS_SQL.define_column(v_cursor_id, 25, v_type.object_type_code, 30);
      DBMS_SQL.define_column(v_cursor_id, 26, v_type.object_id);
      DBMS_SQL.define_column(v_cursor_id, 27, v_type.obect_name, 30);
      DBMS_SQL.define_column(v_cursor_id, 28, v_type.DURATION);
      DBMS_SQL.define_column(v_cursor_id, 29, v_type.duration_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 30, v_type.planned_effort);
      DBMS_SQL.define_column(v_cursor_id, 31, v_type.planned_effort_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 32, v_type.actual_effort);
      DBMS_SQL.define_column(v_cursor_id, 33, v_type.actual_effort_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 34, v_type.percentage_complete);
      DBMS_SQL.define_column(v_cursor_id, 35, v_type.reason_code, 30);
      DBMS_SQL.define_column(v_cursor_id, 36, v_type.private_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 37, v_type.publish_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 38, v_type.multi_booked_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 39, v_type.milestone_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 40, v_type.holiday_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 41, v_type.workflow_process_id);
      DBMS_SQL.define_column(v_cursor_id, 46, v_type.notification_flag, 1);
      DBMS_SQL.define_column(v_cursor_id, 47, v_type.notification_period);
      DBMS_SQL.define_column(v_cursor_id, 48, v_type.notification_period_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 49, v_type.parent_task_id);
      DBMS_SQL.define_column(v_cursor_id, 50, v_type.alarm_start);
      DBMS_SQL.define_column(v_cursor_id, 51, v_type.alarm_start_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 52, v_type.alarm_on, 1);
      DBMS_SQL.define_column(v_cursor_id, 53, v_type.alarm_count);
      DBMS_SQL.define_column(v_cursor_id, 54, v_type.alarm_fired_count);
      DBMS_SQL.define_column(v_cursor_id, 55, v_type.alarm_interval);
      DBMS_SQL.define_column(v_cursor_id, 56, v_type.alarm_interval_uom, 3);
      DBMS_SQL.define_column(v_cursor_id, 57, v_type.attribute1, 150);
      DBMS_SQL.define_column(v_cursor_id, 58, v_type.attribute2, 150);
      DBMS_SQL.define_column(v_cursor_id, 59, v_type.attribute3, 150);
      DBMS_SQL.define_column(v_cursor_id, 60, v_type.attribute4, 150);
      DBMS_SQL.define_column(v_cursor_id, 61, v_type.attribute5, 150);
      DBMS_SQL.define_column(v_cursor_id, 62, v_type.attribute6, 150);
      DBMS_SQL.define_column(v_cursor_id, 63, v_type.attribute7, 150);
      DBMS_SQL.define_column(v_cursor_id, 64, v_type.attribute8, 150);
      DBMS_SQL.define_column(v_cursor_id, 65, v_type.attribute9, 150);
      DBMS_SQL.define_column(v_cursor_id, 66, v_type.attribute10, 150);
      DBMS_SQL.define_column(v_cursor_id, 67, v_type.attribute11, 150);
      DBMS_SQL.define_column(v_cursor_id, 68, v_type.attribute12, 150);
      DBMS_SQL.define_column(v_cursor_id, 69, v_type.attribute13, 150);
      DBMS_SQL.define_column(v_cursor_id, 70, v_type.attribute14, 150);
      DBMS_SQL.define_column(v_cursor_id, 71, v_type.attribute15, 150);
      DBMS_SQL.define_column(v_cursor_id, 72, v_type.attribute_category, 150);
      v_dummy      := DBMS_SQL.EXECUTE(v_cursor_id);
      v_cnt        := 0;

      LOOP
        EXIT WHEN(DBMS_SQL.fetch_rows(v_cursor_id) = 0);
        v_cnt           := v_cnt + 1;
        -- retrieve the rows from the buffer
        DBMS_SQL.column_value(v_cursor_id, 1, v_type.task_id);
        DBMS_SQL.column_value(v_cursor_id, 2, v_type.task_number);
        DBMS_SQL.column_value(v_cursor_id, 3, v_type.task_name);
        DBMS_SQL.column_value(v_cursor_id, 4, v_type.description);
        DBMS_SQL.column_value(v_cursor_id, 5, v_type.task_type_id);
        DBMS_SQL.column_value(v_cursor_id, 6, v_type.task_type);
        DBMS_SQL.column_value(v_cursor_id, 7, v_type.task_status_id);
        DBMS_SQL.column_value(v_cursor_id, 8, v_type.task_status);
        DBMS_SQL.column_value(v_cursor_id, 9, v_type.task_priority_id);
        DBMS_SQL.column_value(v_cursor_id, 10, v_type.task_priority);
        DBMS_SQL.column_value(v_cursor_id, 11, v_type.owner_type_code);
        DBMS_SQL.column_value(v_cursor_id, 12, v_type.owner_id);
        DBMS_SQL.column_value(v_cursor_id, 13, v_type.assigned_by_id);
        DBMS_SQL.column_value(v_cursor_id, 14, v_type.assigned_by_name);
        DBMS_SQL.column_value(v_cursor_id, 15, v_type.customer_id);
        DBMS_SQL.column_value(v_cursor_id, 16, v_type.customer_name);
        DBMS_SQL.column_value(v_cursor_id, 17, v_type.customer_number);
        DBMS_SQL.column_value(v_cursor_id, 18, v_type.address_id);
        DBMS_SQL.column_value(v_cursor_id, 19, v_type.planned_start_date);
        DBMS_SQL.column_value(v_cursor_id, 20, v_type.planned_end_date);
        DBMS_SQL.column_value(v_cursor_id, 21, v_type.scheduled_start_date);
        DBMS_SQL.column_value(v_cursor_id, 22, v_type.scheduled_end_date);
        DBMS_SQL.column_value(v_cursor_id, 23, v_type.actual_start_date);
        DBMS_SQL.column_value(v_cursor_id, 24, v_type.actual_end_date);
        DBMS_SQL.column_value(v_cursor_id, 25, v_type.object_type_code);
        DBMS_SQL.column_value(v_cursor_id, 26, v_type.object_id);
        DBMS_SQL.column_value(v_cursor_id, 27, v_type.obect_name);
        DBMS_SQL.column_value(v_cursor_id, 28, v_type.DURATION);
        DBMS_SQL.column_value(v_cursor_id, 29, v_type.duration_uom);
        DBMS_SQL.column_value(v_cursor_id, 30, v_type.planned_effort);
        DBMS_SQL.column_value(v_cursor_id, 31, v_type.planned_effort_uom);
        DBMS_SQL.column_value(v_cursor_id, 32, v_type.actual_effort);
        DBMS_SQL.column_value(v_cursor_id, 33, v_type.actual_effort_uom);
        DBMS_SQL.column_value(v_cursor_id, 34, v_type.percentage_complete);
        DBMS_SQL.column_value(v_cursor_id, 35, v_type.reason_code);
        DBMS_SQL.column_value(v_cursor_id, 36, v_type.private_flag);
        DBMS_SQL.column_value(v_cursor_id, 37, v_type.publish_flag);
        DBMS_SQL.column_value(v_cursor_id, 38, v_type.multi_booked_flag);
        DBMS_SQL.column_value(v_cursor_id, 39, v_type.milestone_flag);
        DBMS_SQL.column_value(v_cursor_id, 40, v_type.holiday_flag);
        DBMS_SQL.column_value(v_cursor_id, 41, v_type.workflow_process_id);
        DBMS_SQL.column_value(v_cursor_id, 46, v_type.notification_flag);
        DBMS_SQL.column_value(v_cursor_id, 47, v_type.notification_period);
        DBMS_SQL.column_value(v_cursor_id, 48, v_type.notification_period_uom);
        DBMS_SQL.column_value(v_cursor_id, 49, v_type.parent_task_id);
        DBMS_SQL.column_value(v_cursor_id, 50, v_type.alarm_start);
        DBMS_SQL.column_value(v_cursor_id, 51, v_type.alarm_start_uom);
        DBMS_SQL.column_value(v_cursor_id, 52, v_type.alarm_on);
        DBMS_SQL.column_value(v_cursor_id, 53, v_type.alarm_count);
        DBMS_SQL.column_value(v_cursor_id, 54, v_type.alarm_fired_count);
        DBMS_SQL.column_value(v_cursor_id, 55, v_type.alarm_interval);
        DBMS_SQL.column_value(v_cursor_id, 56, v_type.alarm_interval_uom);
        DBMS_SQL.column_value(v_cursor_id, 57, v_type.attribute1);
        DBMS_SQL.column_value(v_cursor_id, 58, v_type.attribute2);
        DBMS_SQL.column_value(v_cursor_id, 59, v_type.attribute3);
        DBMS_SQL.column_value(v_cursor_id, 60, v_type.attribute4);
        DBMS_SQL.column_value(v_cursor_id, 61, v_type.attribute5);
        DBMS_SQL.column_value(v_cursor_id, 62, v_type.attribute6);
        DBMS_SQL.column_value(v_cursor_id, 63, v_type.attribute7);
        DBMS_SQL.column_value(v_cursor_id, 64, v_type.attribute8);
        DBMS_SQL.column_value(v_cursor_id, 65, v_type.attribute9);
        DBMS_SQL.column_value(v_cursor_id, 66, v_type.attribute10);
        DBMS_SQL.column_value(v_cursor_id, 67, v_type.attribute11);
        DBMS_SQL.column_value(v_cursor_id, 68, v_type.attribute12);
        DBMS_SQL.column_value(v_cursor_id, 69, v_type.attribute13);
        DBMS_SQL.column_value(v_cursor_id, 70, v_type.attribute14);
        DBMS_SQL.column_value(v_cursor_id, 71, v_type.attribute15);
        DBMS_SQL.column_value(v_cursor_id, 72, v_type.attribute_category);
        --       'v_type.task_id:'||
        --       to_char(v_type.task_id));
        v_n_tbl(v_cnt)  := v_type;
      END LOOP;
    --dbms_sql.close_cursor(v_cursor_id);
    END IF;   --p_query_or_next_code;

    -- copy records to be returned back
    x_total_retrieved  := v_n_tbl.COUNT;

    -- if table is empty do nothing
    IF (x_total_retrieved > 0) THEN
      IF (p_show_all = 'Y') THEN   -- return all the rows
        v_start  := v_n_tbl.FIRST;
        v_end    := v_n_tbl.LAST;
      ELSE
        v_start  := p_start_pointer;
        v_end    := p_start_pointer + p_rec_wanted - 1;

        IF (v_end > v_n_tbl.LAST) THEN
          v_end  := v_n_tbl.LAST;
        END IF;
      END IF;

      FOR v_cnt IN v_start .. v_end LOOP
        x_task_table(v_cnt)  := v_n_tbl(v_cnt);
      END LOOP;
    END IF;

    x_total_returned   := x_task_table.COUNT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_next_task;
END;

/
