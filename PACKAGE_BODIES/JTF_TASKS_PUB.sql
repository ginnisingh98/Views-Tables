--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_PUB" AS
  /* $Header: jtfptktb.pls 120.15.12010000.5 2010/04/27 06:08:51 anangupt ship $ */
  g_entity         CONSTANT jtf_tasks_b.entity%TYPE                        := 'TASK';
  g_free_busy_type CONSTANT jtf_task_all_assignments.free_busy_type%TYPE   := 'FREE';

  -- new version without table type parameters
  -- Remove the fix of Bug 2152549
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
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  , p_address_number          IN            VARCHAR2 DEFAULT NULL
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pub2;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    -- Remove the fix of Bug 2152549: call create_task_b which is non-overloading procedure
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_number         => p_parent_task_number
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
    , p_task_split_flag            => NULL
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
      ROLLBACK TO create_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pub2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Overloaded Version for the Simplex Fix.
  -- new version without table type parameters
  -- Remove the fix of Bug 2152549
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
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  , p_address_number          IN            VARCHAR2 DEFAULT NULL
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pub1;
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
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_number         => p_parent_task_number
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
    , p_task_assign_tbl            => g_miss_task_assign_tbl
    , p_task_depends_tbl           => g_miss_task_depends_tbl
    , p_task_rsrc_req_tbl          => g_miss_task_rsrc_req_tbl
    , p_task_refer_tbl             => g_miss_task_refer_tbl
    , p_task_dates_tbl             => g_miss_task_dates_tbl
    , p_task_notes_tbl             => g_miss_task_notes_tbl
    , p_task_recur_rec             => g_miss_task_recur_rec
    , p_task_contacts_tbl          => g_miss_task_contacts_tbl
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
      ROLLBACK TO create_task_pub1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pub1;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Overloaded Version for Location Id Enh# 3691788.
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
  , p_customer_id             IN            NUMBER DEFAULT NULL
  , p_cust_account_number     IN            VARCHAR2 DEFAULT NULL
  , p_cust_account_id         IN            NUMBER DEFAULT NULL
  , p_address_id              IN            NUMBER DEFAULT NULL
  , p_address_number          IN            VARCHAR2 DEFAULT NULL
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
  , p_enable_workflow         IN            VARCHAR2 DEFAULT fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
  , p_abort_workflow          IN            VARCHAR2 DEFAULT fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
  , p_task_split_flag         IN            VARCHAR2 DEFAULT NULL
  , p_reference_flag          IN            VARCHAR2 DEFAULT NULL
  , p_child_position          IN            VARCHAR2 DEFAULT NULL
  , p_child_sequence_num      IN            NUMBER DEFAULT NULL
  , p_location_id             IN            NUMBER
  ) IS
    l_api_version    CONSTANT NUMBER                                               := 1.0;
    l_api_name       CONSTANT VARCHAR2(30)                                       := 'VALIDATE_TASK';
    l_task_number             jtf_tasks_b.task_number%TYPE;
    /* Modified by TSINGHAL dt 8/10/2003 for bug fix 3182170 start */
    l_task_name               jtf_tasks_tl.task_name%TYPE;
    /* Modified by TSINGHAL dt 8/10/2003 for bug fix 3182170 End */
    l_task_type_id            jtf_tasks_b.task_type_id%TYPE                       := p_task_type_id;
    l_task_priority_id        jtf_tasks_b.task_priority_id%TYPE               := p_task_priority_id;
    l_task_status_id          jtf_tasks_b.task_status_id%TYPE                   := p_task_status_id;
    l_owner_type_name         jtf_objects_tl.NAME%TYPE                         := p_owner_type_name;
    l_owner_type_code         jtf_objects_b.object_code%TYPE                   := p_owner_type_code;
    l_owner_id                jtf_tasks_b.owner_id%TYPE                            := p_owner_id;
    l_timezone_id             hz_timezones.timezone_id%TYPE                        := p_timezone_id;
    l_timezone_name           hz_timezones.global_timezone_name%TYPE             := p_timezone_name;
    l_planned_start_date      DATE                                          := p_planned_start_date;
    l_planned_end_date        DATE                                            := p_planned_end_date;
    l_actual_start_date       DATE                                           := p_actual_start_date;
    l_actual_end_date         DATE                                             := p_actual_end_date;
    l_scheduled_start_date    DATE                                        := p_scheduled_start_date;
    l_scheduled_end_date      DATE                                          := p_scheduled_end_date;
    l_assigned_by_name        fnd_user.user_name%TYPE                         := p_assigned_by_name;
    l_assigned_by_id          NUMBER                                            := p_assigned_by_id;
    l_cust_account_number     hz_cust_accounts.account_number%TYPE         := p_cust_account_number;
    l_cust_account_id         hz_cust_accounts.cust_account_id%TYPE            := p_cust_account_id;
    l_customer_id             hz_parties.party_id%TYPE                             := p_customer_id;
    l_customer_number         hz_parties.party_number%TYPE                     := p_customer_number;
    l_address_id              hz_party_sites.party_site_id%TYPE                    := p_address_id;
    l_location_id             hz_locations.location_id%TYPE                        := p_location_id;
    l_address_number          hz_party_sites.party_site_number%TYPE             := p_address_number;
    l_parent_task_id          jtf_tasks_b.task_id%TYPE                          := p_parent_task_id;
    l_parent_task_number      jtf_tasks_b.task_number%TYPE                  := p_parent_task_number;
    l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE := p_source_object_type_code;
    l_source_object_id        jtf_tasks_b.source_object_id%TYPE               := p_source_object_id;
    l_source_object_name      jtf_tasks_b.source_object_name%TYPE
                            := jtf_task_utl.check_truncation(p_object_name => p_source_object_name);
    x                         CHAR;
    l_costs                   jtf_tasks_b.costs%TYPE                               := p_costs;
    l_currency_code           jtf_tasks_b.currency_code%TYPE                     := p_currency_code;
    y                         BOOLEAN;
    l_date_selected           jtf_tasks_b.date_selected%TYPE;
    l_owner_status_id         jtf_task_all_assignments.assignment_status_id%TYPE;
    l_type                    VARCHAR2(10);
    l_msg_data                VARCHAR2(2000);   -- debug
    l_task_id                 jtf_tasks_b.task_id%TYPE;
    l_notes_id                NUMBER;
    l_dependency_id           jtf_task_depends.dependency_id%TYPE;
    l_recurrence_rule_id      jtf_task_recur_rules.recurrence_rule_id%TYPE;
    l_resource_req_id         jtf_task_rsc_reqs.resource_req_id%TYPE;
    l_task_rec                jtf_task_recurrences_pub.task_details_rec;
    l_reccurence_generated    NUMBER;
    /*** Start: Added a local variable to fix bug 2107464 ***/
    l_task_contact_id         jtf_task_contacts.task_contact_id%TYPE;
    /*** End: Added a local variable to fix bug 2107464 ***/
    l_task_date_id            jtf_task_dates.task_date_id%TYPE;
    l_task_assignment_id      jtf_task_all_assignments.task_assignment_id%TYPE;
    l_task_reference_id       jtf_task_references_b.task_reference_id%TYPE;
    current_record            INTEGER;

    CURSOR c_owner_status_id(b_owner_status_id jtf_task_all_assignments.assignment_status_id%TYPE) IS
      SELECT task_status_id
        FROM jtf_task_statuses_b
       WHERE task_status_id = b_owner_status_id
         --AND assigned_flag = 'Y'
         AND assignment_status_flag = 'Y'   -- Fix bug 2500664
         AND NVL(end_date_active, SYSDATE) >= SYSDATE
         AND NVL(start_date_active, SYSDATE) <= SYSDATE;
  BEGIN
    SAVEPOINT create_task_pub;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Modified by TSINGHAL bug fix Validate task name length 3182170 Start*/
    l_task_name      := check_param_length(p_task_name, 'JTF_TASK_NAME_INVALID_LENGTH', 80);
    /* Modified by TSINGHAL bug fix 3182170 End*/

    -------
    ------- Validate Task Type
    -------
    jtf_task_utl.validate_task_type(
      p_task_type_id               => l_task_type_id
    , p_task_type_name             => p_task_type_name
    , x_return_status              => x_return_status
    , x_task_type_id               => l_task_type_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_task_type_id IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK_TYPE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Task Status
    -------
    IF l_task_type_id = '22' THEN
      l_type  := 'ESCALATION';
    ELSE
      l_type  := 'TASK';
    END IF;

    jtf_task_utl.validate_task_status(
      p_task_status_id             => l_task_status_id
    , p_task_status_name           => p_task_status_name
    , p_validation_type            => l_type
    , x_return_status              => x_return_status
    , x_task_status_id             => l_task_status_id
    );

    IF l_task_status_id IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK_STATUS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Task Priority
    -------
    jtf_task_utl.validate_task_priority(
      p_task_priority_id           => l_task_priority_id
    , p_task_priority_name         => p_task_priority_name
    , x_return_status              => x_return_status
    , x_task_priority_id           => l_task_priority_id
    );
    -------
    ------- Validate Location Id
    -------
    jtf_task_utl.validate_location_id(
      p_location_id                => l_location_id
    , p_address_id                 => l_address_id
    , p_task_id                    => NULL
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Duration
    -------
    jtf_task_utl.validate_effort
                  (
      p_tag                        => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'DURATION')
    , p_tag_uom                    => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'DURATION_UOM')
    , x_return_status              => x_return_status
    , p_effort                     => p_duration
    , p_effort_uom                 => p_duration_uom
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Planned Effort
    -------
    jtf_task_utl.validate_effort(
      p_tag            => jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'PLANNED_EFFORT')
    , p_tag_uom        => jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'PLANNED_EFFORT_UOM')
    , x_return_status  => x_return_status
    , p_effort         => p_planned_effort
    , p_effort_uom     => p_planned_effort_uom
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Actual Effort
    -------
    jtf_task_utl.validate_effort(
      p_tag             => jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'ACTUAL_EFFORT')
    , p_tag_uom         => jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'ACTUAL_EFFORT_UOM')
    , x_return_status   => x_return_status
    , p_effort          => p_actual_effort
    , p_effort_uom      => p_actual_effort_uom
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Owner and Owner Sub Type
    -------
    jtf_task_utl.validate_task_owner(
      p_owner_type_code            => l_owner_type_code
    , p_owner_type_name            => NULL
    , p_owner_id                   => l_owner_id
    , x_return_status              => x_return_status
    , x_owner_id                   => l_owner_id
    , x_owner_type_code            => l_owner_type_code
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_OWNER');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_owner_id IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_OWNER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_owner_type_code IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_OWNER_TYPE_CODE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Planned Dates
    -------
    jtf_task_utl.validate_dates(
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PLANNED')
    , p_start_date                 => l_planned_start_date
    , p_end_date                   => l_planned_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Actual Dates
    -------
    jtf_task_utl.validate_dates
                 (
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'ACTUAL')
    , p_start_date                 => l_actual_start_date
    , p_end_date                   => l_actual_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Scheduled Dates
    -------
    jtf_task_utl.validate_dates
                 (
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'SCHEDULED')
    , p_start_date                 => l_scheduled_start_date
    , p_end_date                   => l_scheduled_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Timezones
    -------
    jtf_task_utl.validate_timezones(
      p_timezone_id                => l_timezone_id
    , p_timezone_name              => l_timezone_name
    , x_return_status              => x_return_status
    , x_timezone_id                => l_timezone_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate source object details
    -------
    --- only if object is not TASK, fix for bug #2058164
    IF l_source_object_type_code <> 'TASK' THEN
      jtf_task_utl.validate_source_object(
        p_object_code                => l_source_object_type_code
      , p_object_id                  => l_source_object_id
      , p_object_name                => l_source_object_name
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -------
    ------- Call the private flag
    -------
    jtf_task_utl.validate_flag
                (
      x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PRIVATE_FLAG')
    , p_flag_value                 => p_private_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the publish flag
    -------
    jtf_task_utl.validate_flag
                (
      x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PUBLISH_FLAG')
    , p_flag_value                 => p_publish_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Restrict closure  flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'RESTRICT_CLOSURE_FLAG')
    , p_flag_value                 => p_restrict_closure_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Multi Booked flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'MULTIBOOKED_FLAG')
    , p_flag_value                 => p_multi_booked_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the milestone flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'MILESTONE_FLAG')
    , p_flag_value                 => p_milestone_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Holiday Flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'HOLIDAY_FLAG')
    , p_flag_value                 => p_holiday_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Billable Flag
    -------
    jtf_task_utl.validate_flag
                (
      x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'BILLABLE_FLAG')
    , p_flag_value                 => p_billable_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Validate Notification Parameters
    -------
    jtf_task_utl.validate_notification(
      p_notification_flag          => p_notification_flag
    , p_notification_period        => p_notification_period
    , p_notification_period_uom    => p_notification_period_uom
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the soft bound Flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'SOFTBOUND_FLAG')
    , p_flag_value                 => p_soft_bound_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Palm Flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PALM_FLAG')
    , p_flag_value                 => p_palm_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Wince Flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'WINCE_FLAG')
    , p_flag_value                 => p_wince_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Call the Laptop Flag
    -------
    jtf_task_utl.validate_flag
                (
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => x_return_status
    , p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'LAPTOP_FLAG')
    , p_flag_value                 => p_laptop_flag
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validating the alarm details
    -------
    jtf_task_utl.validate_alarm(
      p_alarm_start                => p_alarm_start
    , p_alarm_start_uom            => p_alarm_start_uom
    , p_alarm_on                   => p_alarm_on
    , p_alarm_count                => p_alarm_count
    , p_alarm_interval             => p_alarm_interval
    , p_alarm_interval_uom         => p_alarm_interval_uom
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validating the assigned_by_id
    -------
    jtf_task_utl.validate_assigned_by(
      p_assigned_by_id             => l_assigned_by_id
    , p_assigned_by_name           => l_assigned_by_name
    , x_return_status              => x_return_status
    , x_assigned_by_id             => l_assigned_by_id
    );   -------
    ------- Validating the parent task id
    -------
    -- Fix Bug 2119074 : Must validate p_parent_task_number when p_parent_task_id is null
    --IF p_parent_task_id IS NOT NULL
    --THEN
    jtf_task_utl.validate_task(
      p_task_id                    => l_parent_task_id
    , p_task_number                => l_parent_task_number
    , x_task_id                    => l_parent_task_id
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --END IF;

    -------
    ------- Call the Customer Info
    -------
    jtf_task_utl.validate_customer_info(
      p_cust_account_number        => l_cust_account_number
    , p_cust_account_id            => l_cust_account_id
    , p_customer_number            => l_customer_number
    , p_customer_id                => l_customer_id
    , p_address_id                 => l_address_id
    , p_address_number             => l_address_number
    , x_return_status              => x_return_status
    , x_cust_account_id            => l_cust_account_id
    , x_customer_id                => l_customer_id
    , x_address_id                 => l_address_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Percentage Complete
    -------
    IF p_percentage_complete IS NOT NULL THEN
      IF p_percentage_complete < 0 OR p_percentage_complete > 100 THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_PCT_COMPLETE');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -------
    ------- Bound mode code.
    -------
    IF p_bound_mode_code IS NOT NULL THEN
      y  := jtf_task_utl.validate_lookup('JTF_TASK_BOUND_MODE_CODE', p_bound_mode_code, NULL);

      IF y = FALSE THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -------
    ------- Validating costs
    -------
    jtf_task_utl.validate_costs(p_costs => l_costs, p_currency_code => l_currency_code
    , x_return_status              => x_return_status);

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ---------------
    ---------------  Validate date_selected
    ---------------
    IF l_date_selected IS NOT NULL AND l_date_selected <> fnd_api.g_miss_char THEN
      IF l_date_selected NOT IN('P', 'S', 'A', 'D') THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    ---------------
    ---------------  Validate owner_status_id
    ---------------
    IF p_owner_status_id IS NOT NULL AND p_owner_status_id <> fnd_api.g_miss_num THEN
      OPEN c_owner_status_id(p_owner_status_id);

      FETCH c_owner_status_id
       INTO l_owner_status_id;

      IF c_owner_status_id%NOTFOUND THEN
        CLOSE c_owner_status_id;

        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        CLOSE c_owner_status_id;
      END IF;
    END IF;

    -------
    ------- Call the private api.
    -------
    jtf_tasks_pvt.create_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_type_id               => l_task_type_id
    , p_task_name                  => l_task_name
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_id                    => x_task_id
    , p_task_status_id             => l_task_status_id
    , p_task_priority_id           => l_task_priority_id
    , p_owner_id                   => l_owner_id
    , p_owner_type_code            => l_owner_type_code
    , p_owner_territory_id         => p_owner_territory_id
    , p_source_object_id           => l_source_object_id
    , p_source_object_name         => l_source_object_name
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
    , p_parent_task_id             => l_parent_task_id
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
    , p_assigned_by_id             => l_assigned_by_id
    , p_cust_account_id            => p_cust_account_id
    , p_customer_id                => p_customer_id
    , p_address_id                 => p_address_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_source_object_type_code    => l_source_object_type_code
    , p_timezone_id                => l_timezone_id
    , p_description                => p_description
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
    , p_escalation_level           => p_escalation_level
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
    , p_owner_status_id            => l_owner_status_id
    , p_template_id                => p_template_id
    , p_template_group_id          => p_template_group_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_entity                     => g_entity
    , p_free_busy_type             => g_free_busy_type
    , p_task_confirmation_status   => 'N'
    , p_task_confirmation_counter  => 0
    , p_task_split_flag            => p_task_split_flag
    , p_reference_flag             => p_reference_flag
    , p_child_position             => p_child_position
    , p_child_sequence_num         => p_child_sequence_num
    , p_location_id                => l_location_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_task_id        := x_task_id;

    -------
    -------
    ------- Create the dependencies
    -------
    -------
    IF p_task_depends_tbl.COUNT > 0 THEN
      current_record  := p_task_depends_tbl.FIRST;

      FOR i IN 1 .. p_task_depends_tbl.COUNT LOOP
        jtf_task_dependency_pub.create_task_dependency
          (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_validation_level           => fnd_api.g_valid_level_full
        , p_task_id                    => l_task_id
        , p_dependent_on_task_id       => p_task_depends_tbl(current_record).dependent_on_task_id
        , p_dependent_on_task_number   => p_task_depends_tbl(current_record).dependent_on_task_number
        , p_dependency_type_code       => p_task_depends_tbl(current_record).dependency_type_code
        , p_template_flag              => jtf_task_utl.g_no
        , p_adjustment_time            => p_task_depends_tbl(current_record).adjustment_time
        , p_adjustment_time_uom        => p_task_depends_tbl(current_record).adjustment_time_uom
        , p_validated_flag             => p_task_depends_tbl(current_record).validated_flag
        , x_dependency_id              => l_dependency_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_depends_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    ------- Create References
    -------
    IF p_task_refer_tbl.COUNT > 0 THEN
      current_record  := p_task_refer_tbl.FIRST;

      FOR i IN 1 .. p_task_refer_tbl.COUNT LOOP
        jtf_task_references_pub.create_references
                          (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_id
        , p_object_type_code           => p_task_refer_tbl(current_record).object_type_code
        ,
          --          p_object_type_name => p_task_refer_tbl (current_record).object_type_name,
          p_object_name                => p_task_refer_tbl(current_record).object_name
        , p_object_id                  => p_task_refer_tbl(current_record).object_id
        , p_object_details             => p_task_refer_tbl(current_record).object_details
        , p_reference_code             => p_task_refer_tbl(current_record).reference_code
        , p_usage                      => p_task_refer_tbl(current_record).USAGE
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_reference_id          => l_task_reference_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_refer_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    ------- Create Resource Requirements
    -------
    IF p_task_rsrc_req_tbl.COUNT > 0 THEN
      current_record  := p_task_rsrc_req_tbl.FIRST;

      FOR i IN 1 .. p_task_rsrc_req_tbl.COUNT LOOP
        jtf_task_resources_pub.create_task_rsrc_req
                                 (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_id
        , p_resource_type_code         => p_task_rsrc_req_tbl(i).resource_type_code
        , p_required_units             => p_task_rsrc_req_tbl(i).required_units
        , p_enabled_flag               => p_task_rsrc_req_tbl(i).enabled_flag
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_resource_req_id            => l_resource_req_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_rsrc_req_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    ------- Create Assignments
    -------
    IF p_task_assign_tbl.COUNT > 0 THEN
      current_record  := p_task_assign_tbl.FIRST;

      FOR i IN 1 .. p_task_assign_tbl.COUNT LOOP
        jtf_task_assignments_pub.create_task_assignment
                   (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_id
        , p_resource_type_code         => p_task_assign_tbl(i).resource_type_code
        , p_resource_id                => p_task_assign_tbl(i).resource_id
        , p_actual_effort              => p_task_assign_tbl(i).actual_effort
        , p_actual_effort_uom          => p_task_assign_tbl(i).actual_effort_uom
        , p_schedule_flag              => p_task_assign_tbl(i).schedule_flag
        , p_alarm_type_code            => p_task_assign_tbl(i).alarm_type_code
        , p_alarm_contact              => p_task_assign_tbl(i).alarm_contact
        , p_sched_travel_distance      => p_task_assign_tbl(i).sched_travel_duration
        , p_sched_travel_duration      => p_task_assign_tbl(i).sched_travel_duration
        , p_sched_travel_duration_uom  => p_task_assign_tbl(i).sched_travel_duration_uom
        , p_actual_travel_distance     => p_task_assign_tbl(i).actual_travel_distance
        , p_actual_travel_duration     => p_task_assign_tbl(i).actual_travel_duration
        , p_actual_travel_duration_uom => p_task_assign_tbl(i).actual_travel_duration_uom
        , p_actual_start_date          => p_task_assign_tbl(i).actual_start_date
        , p_actual_end_date            => p_task_assign_tbl(i).actual_end_date
        , p_palm_flag                  => p_task_assign_tbl(i).palm_flag
        , p_wince_flag                 => p_task_assign_tbl(i).wince_flag
        , p_laptop_flag                => p_task_assign_tbl(i).laptop_flag
        , p_device1_flag               => p_task_assign_tbl(i).device1_flag
        , p_device2_flag               => p_task_assign_tbl(i).device2_flag
        , p_device3_flag               => p_task_assign_tbl(i).device3_flag
        , p_resource_territory_id      => p_task_assign_tbl(i).resource_territory_id
        , p_assignment_status_id       => p_task_assign_tbl(i).assignment_status_id
        , p_shift_construct_id         => p_task_assign_tbl(i).shift_construct_id
        , p_show_on_calendar           => p_task_assign_tbl(i).show_on_calendar
        , p_category_id                => p_task_assign_tbl(i).category_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_assignment_id         => l_task_assignment_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_rsrc_req_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    ------- Create Dates
    -------
    IF p_task_dates_tbl.COUNT > 0 THEN
      current_record  := p_task_dates_tbl.FIRST;

      FOR i IN 1 .. p_task_dates_tbl.COUNT LOOP
        jtf_task_dates_pub.create_task_dates
                              (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_id
        , p_date_type_id               => p_task_dates_tbl(current_record).date_type_id
        , p_date_type_name             => p_task_dates_tbl(current_record).date_type_name
        , p_date_value                 => p_task_dates_tbl(current_record).date_value
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_date_id               => l_task_date_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_dates_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    ------- Create Notes
    -------
    IF p_task_notes_tbl.COUNT > 0 THEN
      current_record  := p_task_notes_tbl.FIRST;

      FOR i IN 1 .. p_task_notes_tbl.COUNT LOOP
        jtf_notes_pub.create_note(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_validation_level           => fnd_api.g_valid_level_full
        , p_parent_note_id             => p_task_notes_tbl(i).parent_note_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_count
        , p_org_id                     => p_task_notes_tbl(i).org_id
        , p_source_object_id           => l_task_id
        , p_source_object_code         => 'TASK'
        , p_notes                      => p_task_notes_tbl(i).notes
        , p_notes_detail               => p_task_notes_tbl(i).notes_detail
        , p_note_status                => p_task_notes_tbl(i).note_status
        , p_entered_by                 => p_task_notes_tbl(i).entered_by
        , p_entered_date               => p_task_notes_tbl(i).entered_date
        , x_jtf_note_id                => l_notes_id
        , p_note_type                  => p_task_notes_tbl(i).note_type
        , p_jtf_note_contexts_tab      => jtf_notes_pub.jtf_note_contexts_tab
        , p_creation_date              => SYSDATE
        , p_last_update_date           => SYSDATE
        , p_last_updated_by            => fnd_global.login_id
        , p_attribute1                 => p_task_notes_tbl(i).attribute1
        , p_attribute2                 => p_task_notes_tbl(i).attribute2
        , p_attribute3                 => p_task_notes_tbl(i).attribute3
        , p_attribute4                 => p_task_notes_tbl(i).attribute4
        , p_attribute5                 => p_task_notes_tbl(i).attribute5
        , p_attribute6                 => p_task_notes_tbl(i).attribute6
        , p_attribute7                 => p_task_notes_tbl(i).attribute7
        , p_attribute8                 => p_task_notes_tbl(i).attribute8
        , p_attribute9                 => p_task_notes_tbl(i).attribute9
        , p_attribute10                => p_task_notes_tbl(i).attribute10
        , p_attribute11                => p_task_notes_tbl(i).attribute11
        , p_attribute12                => p_task_notes_tbl(i).attribute12
        , p_attribute13                => p_task_notes_tbl(i).attribute13
        , p_attribute14                => p_task_notes_tbl(i).attribute14
        , p_attribute15                => p_task_notes_tbl(i).attribute15
        , p_context                    => p_task_notes_tbl(i).CONTEXT
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        current_record  := p_task_dates_tbl.NEXT(current_record);
      END LOOP;
    END IF;

    -------
    -------
    ------- Create recurrences
    -------
    -------
    IF (
           p_task_recur_rec.occurs_which IS NOT NULL
        OR p_task_recur_rec.day_of_week IS NOT NULL
        OR p_task_recur_rec.date_of_month IS NOT NULL
        OR p_task_recur_rec.occurs_month IS NOT NULL
        OR p_task_recur_rec.occurs_uom IS NOT NULL
        OR p_task_recur_rec.occurs_every IS NOT NULL
        OR p_task_recur_rec.occurs_number IS NOT NULL
        OR p_task_recur_rec.start_date_active IS NOT NULL
        OR p_task_recur_rec.end_date_active IS NOT NULL
       ) THEN
      jtf_task_recurrences_pub.create_task_recurrence
                                        (
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => l_task_id
      , p_occurs_which               => p_task_recur_rec.occurs_which
      , p_template_flag              => jtf_task_utl.g_no
      , p_day_of_week                => p_task_recur_rec.day_of_week
      , p_date_of_month              => p_task_recur_rec.date_of_month
      , p_occurs_month               => p_task_recur_rec.occurs_month
      , p_occurs_uom                 => p_task_recur_rec.occurs_uom
      , p_occurs_every               => p_task_recur_rec.occurs_every
      , p_occurs_number              => p_task_recur_rec.occurs_number
      , p_start_date_active          => p_task_recur_rec.start_date_active
      , p_end_date_active            => p_task_recur_rec.end_date_active
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_recurrence_rule_id         => l_recurrence_rule_id
      , x_task_rec                   => l_task_rec
      , x_reccurences_generated      => l_reccurence_generated
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    /***** Start: Fix bug 2107464 ***************/
    -------
    ------- Create Contacts
    -------
    IF p_task_contacts_tbl.COUNT > 0 THEN
      --current_record := p_task_contacts_tbl.FIRST;
      FOR i IN p_task_contacts_tbl.FIRST .. p_task_contacts_tbl.COUNT LOOP
        jtf_task_contacts_pub.create_task_contacts
                   (
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_id
        , p_contact_id                 => p_task_contacts_tbl(i).contact_id
        , p_contact_type_code          => p_task_contacts_tbl(i).contact_type_code
        , p_escalation_notify_flag     => p_task_contacts_tbl(i).escalation_notify_flag
        , p_escalation_requester_flag  => p_task_contacts_tbl(i).escalation_requester_flag
        , x_task_contact_id            => l_task_contact_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      --current_record := p_task_dates_tbl.NEXT (current_record);
      END LOOP;
    END IF;

    /***** End: Fix bug 2107464 ***************/

    -------
    -------
    -------
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pub;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- original version including table type parameters
  -- Remove the fix of Bug 2152549
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
  BEGIN
    SAVEPOINT create_task_pub2;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
          -- Remove the fix of Bug 2152549: call create_task_b which is non-overloading procedure
    create_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    ,
      -- passing FALSE so we can commit after processing the table parameters
      p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_number         => p_parent_task_number
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
    , p_task_assign_tbl            => p_task_assign_tbl
    , p_task_depends_tbl           => p_task_depends_tbl
    , p_task_rsrc_req_tbl          => p_task_rsrc_req_tbl
    , p_task_refer_tbl             => p_task_refer_tbl
    , p_task_dates_tbl             => p_task_dates_tbl
    , p_task_notes_tbl             => p_task_notes_tbl
    , p_task_recur_rec             => p_task_recur_rec
    , p_task_contacts_tbl          => p_task_contacts_tbl
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
    , p_task_split_flag            => NULL
    , p_reference_flag             => NULL
    , p_child_position             => NULL
    , p_child_sequence_num         => NULL
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
      ROLLBACK TO create_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_pub2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Old Version
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
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_TASK';
  BEGIN
    SAVEPOINT update_task_pub1;

    -----------
    -----------
    -----------
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    update_task
             (
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    ,   --commented out as it cleared stack fnd_api.g_true,
      p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_number                => p_task_number
    , p_task_name                  => p_task_name
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_id             => p_parent_task_id
    , p_parent_task_number         => p_parent_task_number
    , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
    , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    -------
    -------
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pub1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pub1;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Old Version
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
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_TASK';
  BEGIN
    SAVEPOINT update_task_pub2;

    -----------
    -----------
    -----------
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    update_task
             (
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    ,   --commented out as it cleared stack fnd_api.g_true,
      p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_number                => p_task_number
    , p_task_name                  => p_task_name
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_id             => p_parent_task_id
    , p_parent_task_number         => p_parent_task_number
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_task_split_flag            => fnd_api.g_miss_char
    , p_child_position             => fnd_api.g_miss_char
    , p_child_sequence_num         => fnd_api.g_miss_num
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    -------
    -------
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pub2;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Old version
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
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_TASK';
  BEGIN
    SAVEPOINT update_task_pub3;

    -----------
    -----------
    -----------
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    update_task
             (
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    ,   --commented out as it cleared stack fnd_api.g_true,
      p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_number                => p_task_number
    , p_task_name                  => p_task_name
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_description                => p_description
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_name            => p_owner_type_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_name           => p_assigned_by_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_customer_number            => p_customer_number
    , p_customer_id                => p_customer_id
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_address_id                 => p_address_id
    , p_address_number             => p_address_number
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_timezone_id                => p_timezone_id
    , p_timezone_name              => p_timezone_name
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
    , p_parent_task_id             => p_parent_task_id
    , p_parent_task_number         => p_parent_task_number
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    , p_task_split_flag            => p_task_split_flag
    , p_child_position             => p_child_position
    , p_child_sequence_num         => p_child_sequence_num
    , p_location_id                => fnd_api.g_miss_num
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    -------
    -------
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pub3;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_pub3;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

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
  , p_customer_id             IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_cust_account_number     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_cust_account_id         IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_id              IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_address_number          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
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
  ) IS
    l_api_version    CONSTANT NUMBER                                               := 1.0;
    l_api_name       CONSTANT VARCHAR2(30)                                         := 'UPDATE_TASK';
    l_task_id                 jtf_tasks_b.task_id%TYPE                             := p_task_id;
    l_task_number             jtf_tasks_b.task_number%TYPE                         := p_task_number;
    /* Modified by TSINGHAL dt 8/10/2003 for bug fix 3182170 start */
    l_task_name               jtf_tasks_tl.task_name%TYPE;
    /* Modified by TSINGHAL dt 8/10/2003 for bug fix 3182170 End */
    l_task_type_name          jtf_task_types_tl.NAME%TYPE                       := p_task_type_name;
    l_task_type_id            jtf_task_types_b.task_type_id%TYPE                  := p_task_type_id;
    l_task_status_name        jtf_task_statuses_tl.NAME%TYPE                  := p_task_status_name;
    l_task_status_id          jtf_task_statuses_b.task_status_id%TYPE           := p_task_status_id;
    l_task_priority_name      jtf_task_priorities_tl.NAME%TYPE              := p_task_priority_name;
    l_task_priority_id        jtf_task_priorities_b.task_priority_id%TYPE     := p_task_priority_id;
    l_assigned_by_name        fnd_user.user_name%TYPE                         := p_assigned_by_name;
    l_assigned_by_id          NUMBER                                            := p_assigned_by_id;
    l_customer_id             hz_parties.party_id%TYPE;
    l_customer_number         hz_parties.party_number%TYPE;
    l_cust_account_id         hz_cust_accounts.cust_account_id%TYPE;
    l_cust_account_number     hz_cust_accounts.account_number%TYPE;
    l_address_id              hz_party_sites.party_site_id%TYPE;
    l_location_id             hz_locations.location_id%TYPE;
    l_address_number          hz_party_sites.party_site_number%TYPE;
    l_planned_start_date      DATE;
    l_planned_end_date        DATE;
    l_scheduled_start_date    DATE;
    l_scheduled_end_date      DATE;
    l_actual_start_date       DATE;
    l_actual_end_date         DATE;
    l_source_object_type_code jtf_tasks_b.source_object_type_code%TYPE;
    l_source_object_id        jtf_tasks_b.source_object_id%TYPE;
    l_source_object_name      jtf_tasks_b.source_object_name%TYPE;
    l_timezone_id             jtf_tasks_b.timezone_id%TYPE                         := p_timezone_id;
    l_timezone_name           hz_timezones.global_timezone_name%TYPE             := p_timezone_name;
    l_duration                jtf_tasks_b.DURATION%TYPE;
    l_duration_uom            jtf_tasks_b.duration_uom%TYPE;
    l_owner_type_code         jtf_tasks_b.owner_type_code%TYPE;
    l_owner_id                jtf_tasks_b.owner_id%TYPE;
    l_percentage_complete     jtf_tasks_b.percentage_complete%TYPE;
    l_reason_code             jtf_tasks_b.reason_code%TYPE;
    l_private_flag            jtf_tasks_b.private_flag%TYPE;
    l_publish_flag            jtf_tasks_b.publish_flag%TYPE;
    l_restrict_closure_flag   jtf_tasks_b.restrict_closure_flag%TYPE;
    l_multi_booked_flag       jtf_tasks_b.multi_booked_flag%TYPE;
    l_palm_flag               jtf_tasks_b.palm_flag%TYPE;
    l_wince_flag              jtf_tasks_b.wince_flag%TYPE;
    l_laptop_flag             jtf_tasks_b.laptop_flag%TYPE;
    l_device1_flag            jtf_tasks_b.device1_flag%TYPE;
    l_device2_flag            jtf_tasks_b.device2_flag%TYPE;
    l_device3_flag            jtf_tasks_b.device3_flag%TYPE;
    l_description             jtf_tasks_tl.description%TYPE;
    l_planned_effort          jtf_tasks_b.planned_effort%TYPE;
    l_planned_effort_uom      jtf_tasks_b.planned_effort_uom%TYPE;
    l_actual_effort           jtf_tasks_b.actual_effort%TYPE;
    l_actual_effort_uom       jtf_tasks_b.actual_effort_uom%TYPE;
    l_milestone_flag          jtf_tasks_b.milestone_flag%TYPE;
    l_holiday_flag            jtf_tasks_b.holiday_flag%TYPE;
    l_currency_code           jtf_tasks_b.currency_code%TYPE;
    l_costs                   jtf_tasks_b.costs%TYPE;
    l_notification_flag       jtf_tasks_b.notification_flag%TYPE;
    l_notification_period     jtf_tasks_b.notification_period%TYPE;
    l_notification_period_uom jtf_tasks_b.notification_period_uom%TYPE;
    l_billable_flag           jtf_tasks_b.billable_flag%TYPE;
    l_bound_mode_code         jtf_tasks_b.bound_mode_code%TYPE;
    l_soft_bound_flag         jtf_tasks_b.soft_bound_flag%TYPE;
    l_workflow_process_id     jtf_tasks_b.workflow_process_id%TYPE;
    l_parent_task_id          jtf_tasks_b.parent_task_id%TYPE;
    l_parent_task_number      jtf_tasks_b.task_number%TYPE;
    l_alarm_start             jtf_tasks_b.alarm_start%TYPE;
    l_alarm_start_uom         jtf_tasks_b.alarm_start_uom%TYPE;
    l_alarm_on                jtf_tasks_b.alarm_on%TYPE;
    l_alarm_count             jtf_tasks_b.alarm_count%TYPE;
    l_alarm_fired_count       jtf_tasks_b.alarm_fired_count%TYPE;
    l_alarm_interval          jtf_tasks_b.alarm_interval%TYPE;
    l_alarm_interval_uom      jtf_tasks_b.alarm_interval_uom%TYPE;
    l_owner_type_name         jtf_objects_tl.NAME%TYPE;
    l_date_selected           jtf_tasks_b.date_selected%TYPE;
    l_type                    VARCHAR2(10);
    y                         BOOLEAN;
    l_task_split_flag         jtf_tasks_b.task_split_flag%TYPE;

    CURSOR c_task_update(l_task_id IN NUMBER) IS
      SELECT DECODE(p_task_id, fnd_api.g_miss_num, task_id, p_task_id) task_id
           , DECODE(p_task_number, fnd_api.g_miss_char, task_number, p_task_number) task_number
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
           , DECODE(p_location_id, fnd_api.g_miss_num, location_id, p_location_id) location_id
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
               p_source_object_type_code
             , fnd_api.g_miss_char, source_object_type_code
             , p_source_object_type_code
             ) source_object_type_code
           , DECODE(p_source_object_id, fnd_api.g_miss_num, source_object_id, p_source_object_id)
                                                                                   source_object_id
           , DECODE(
               p_source_object_name
             , fnd_api.g_miss_char, source_object_name
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
               p_workflow_process_id
             , fnd_api.g_miss_num, workflow_process_id
             , p_workflow_process_id
             ) workflow_process_id
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
           , DECODE(p_date_selected, fnd_api.g_miss_char, date_selected, p_date_selected)
                                                                                      date_selected
           , DECODE(p_parent_task_id, fnd_api.g_miss_num, parent_task_id, p_parent_task_id)
                                                                                     parent_task_id
           , DECODE(p_task_split_flag, fnd_api.g_miss_char, task_split_flag, p_task_split_flag)
                                                                                    task_split_flag
           , DECODE(p_child_position, fnd_api.g_miss_char, child_position, p_child_position)
                                                                                     child_position
           , DECODE(
               p_child_sequence_num
             , fnd_api.g_miss_num, child_sequence_num
             , p_child_sequence_num
             ) child_sequence_num
        FROM jtf_tasks_vl
       WHERE task_id = l_task_id;

    task_rec                  c_task_update%ROWTYPE;


  BEGIN
    SAVEPOINT update_task_pub;

    -----------
    -----------
    -----------
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Modified by TSINGHAL bug fix Validate task name length 3182170 Start*/
    l_task_name                :=
                                 check_param_length(p_task_name, 'JTF_TASK_NAME_INVALID_LENGTH', 80);
    /* Modified by TSINGHAL bug fix 3182170 End*/

    /*  --------
          -------- Call the Internal User Hook
          --------
          p_task_user_hooks.task_id := p_task_id;
          p_task_user_hooks.task_name := p_task_name;
          p_task_user_hooks.task_type_name := p_task_type_name;
          p_task_user_hooks.task_type_id := p_task_type_id;
          p_task_user_hooks.description := p_description;
          p_task_user_hooks.task_status_name := p_task_status_name;
          p_task_user_hooks.task_status_id := p_task_status_id;
          p_task_user_hooks.task_priority_name := p_task_priority_name;
          p_task_user_hooks.task_priority_id := p_task_priority_id;
          p_task_user_hooks.owner_type_name := p_owner_type_name;
          p_task_user_hooks.owner_type_code := p_owner_type_code;
          p_task_user_hooks.owner_id := p_owner_id;
          p_task_user_hooks.owner_territory_id := p_owner_territory_id;
          p_task_user_hooks.assigned_by_name := p_assigned_by_name;
          p_task_user_hooks.assigned_by_id := p_assigned_by_id;
          p_task_user_hooks.customer_number := p_customer_number;
          p_task_user_hooks.customer_id := p_customer_id;
          p_task_user_hooks.cust_account_number := p_cust_account_number;
          p_task_user_hooks.cust_account_id := p_cust_account_id;
          p_task_user_hooks.address_id := p_address_id;
          p_task_user_hooks.location_id := p_location_id;
          p_task_user_hooks.address_number := p_address_number;
          p_task_user_hooks.planned_start_date := p_planned_start_date;
          p_task_user_hooks.planned_end_date := p_planned_end_date;
          p_task_user_hooks.scheduled_start_date := p_scheduled_start_date;
          p_task_user_hooks.scheduled_end_date := p_scheduled_end_date;
          p_task_user_hooks.actual_start_date := p_actual_start_date;
          p_task_user_hooks.actual_end_date := p_actual_end_date;
          p_task_user_hooks.timezone_id := p_timezone_id;
          p_task_user_hooks.timezone_name := p_timezone_name;
          p_task_user_hooks.source_object_type_code := p_source_object_type_code;
          p_task_user_hooks.source_object_id := p_source_object_id;
          p_task_user_hooks.source_object_name := p_source_object_name;
          p_task_user_hooks.duration := p_duration;
          p_task_user_hooks.duration_uom := p_duration_uom;
          p_task_user_hooks.planned_effort := p_planned_effort;
          p_task_user_hooks.planned_effort_uom := p_planned_effort_uom;
          p_task_user_hooks.actual_effort := p_actual_effort;
          p_task_user_hooks.actual_effort_uom := p_actual_effort_uom;
          p_task_user_hooks.percentage_complete := p_percentage_complete;
          p_task_user_hooks.reason_code := p_reason_code;
          p_task_user_hooks.private_flag := p_private_flag;
          p_task_user_hooks.publish_flag := p_publish_flag;
          p_task_user_hooks.restrict_closure_flag := p_restrict_closure_flag;
          p_task_user_hooks.multi_booked_flag := p_multi_booked_flag;
          p_task_user_hooks.milestone_flag := p_milestone_flag;
          p_task_user_hooks.holiday_flag := p_holiday_flag;
          p_task_user_hooks.billable_flag := p_billable_flag;
          p_task_user_hooks.bound_mode_code := p_bound_mode_code;
          p_task_user_hooks.soft_bound_flag := p_soft_bound_flag;
          p_task_user_hooks.workflow_process_id := p_workflow_process_id;
          p_task_user_hooks.notification_flag := p_notification_flag;
          p_task_user_hooks.notification_period := p_notification_period;
          p_task_user_hooks.notification_period_uom := p_notification_period_uom;
          p_task_user_hooks.alarm_start := p_alarm_start;
          p_task_user_hooks.alarm_start_uom := p_alarm_start_uom;
          p_task_user_hooks.alarm_on := p_alarm_on;
          p_task_user_hooks.alarm_count := p_alarm_count;
          p_task_user_hooks.alarm_interval := p_alarm_interval;
          p_task_user_hooks.alarm_interval_uom := p_alarm_interval_uom;
          p_task_user_hooks.palm_flag := p_palm_flag;
          p_task_user_hooks.wince_flag := p_wince_flag;
          p_task_user_hooks.laptop_flag := p_laptop_flag;
          p_task_user_hooks.device1_flag := p_device1_flag;
          p_task_user_hooks.device2_flag := p_device2_flag;
          p_task_user_hooks.device3_flag := p_device3_flag;
          p_task_user_hooks.costs := p_costs;
          p_task_user_hooks.currency_code := p_currency_code;
          p_task_user_hooks.escalation_level := p_escalation_level;

          jtf_tasks_iuhk.update_task_pre (x_return_status);

          IF NOT (x_return_status = fnd_api.g_ret_sts_success)
          THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
          END IF;

    */
    x_return_status            := fnd_api.g_ret_sts_success;

    -----
    -----   Validate Tasks
    -----
    IF (l_task_id = fnd_api.g_miss_num AND l_task_number = fnd_api.g_miss_char) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      SELECT DECODE(l_task_id, fnd_api.g_miss_num, NULL, l_task_id)
        INTO l_task_id
        FROM DUAL;

      SELECT DECODE(l_task_number, fnd_api.g_miss_char, NULL, l_task_number)
        INTO l_task_number
        FROM DUAL;

      jtf_task_utl.validate_task(
        p_task_id                    => l_task_id
      , p_task_number                => l_task_number
      , x_task_id                    => l_task_id
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_task_id IS NULL THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_NUMBER');
        fnd_message.set_token('P_TASK_NUMBER', l_task_number);
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    -----
    ----- Task Name
    -----
    IF l_task_name IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_NAME');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -----
    ----- Task Description
    -----
    l_description              := task_rec.description;

    OPEN c_task_update(l_task_id);

    FETCH c_task_update
     INTO task_rec;

    IF c_task_update%NOTFOUND THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
      fnd_message.set_token('P_TASK_ID', l_task_id);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -----
    ----- Task Type
    -----
    IF (l_task_type_name = fnd_api.g_miss_char AND l_task_type_id = fnd_api.g_miss_num) THEN
      l_task_type_id  := task_rec.task_type_id;
    ELSIF(l_task_type_name = fnd_api.g_miss_char AND l_task_type_id <> fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_type(
        p_task_type_id               => l_task_type_id
      , p_task_type_name             => NULL
      , x_return_status              => x_return_status
      , x_task_type_id               => l_task_type_id
      );
    ELSIF(l_task_type_name <> fnd_api.g_miss_char AND l_task_type_id = fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_type(
        p_task_type_id               => NULL
      , p_task_type_name             => l_task_type_name
      , x_return_status              => x_return_status
      , x_task_type_id               => l_task_type_id
      );
    ELSE
      jtf_task_utl.validate_task_type(
        p_task_type_id               => l_task_type_id
      , p_task_type_name             => l_task_type_name
      , x_return_status              => x_return_status
      , x_task_type_id               => l_task_type_id
      );
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_task_type_id IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TYPE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate Location Id
    -------
    jtf_task_utl.validate_location_id(
      p_location_id                => p_location_id
    , p_address_id                 => p_address_id
    , p_task_id                    => l_task_id
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -----
    -----   Task Status
    -----
    IF l_task_type_id = '22' THEN
      l_type  := 'ESCALATION';
    ELSE
      l_type  := 'TASK';
    END IF;

    IF (l_task_status_name = fnd_api.g_miss_char AND l_task_status_id = fnd_api.g_miss_num) THEN
      l_task_status_id  := task_rec.task_status_id;
    ELSIF(l_task_status_name = fnd_api.g_miss_char AND l_task_status_id <> fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_status(
        p_task_status_id             => l_task_status_id
      , p_task_status_name           => NULL
      , p_validation_type            => l_type
      , x_return_status              => x_return_status
      , x_task_status_id             => l_task_status_id
      );
    ELSIF(l_task_status_name <> fnd_api.g_miss_char AND l_task_status_id = fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_status(
        p_task_status_id             => NULL
      , p_task_status_name           => l_task_status_name
      , p_validation_type            => l_type
      , x_return_status              => x_return_status
      , x_task_status_id             => l_task_status_id
      );
    ELSE
      jtf_task_utl.validate_task_status(
        p_task_status_id             => l_task_status_id
      , p_task_status_name           => l_task_status_name
      , p_validation_type            => l_type
      , x_return_status              => x_return_status
      , x_task_status_id             => l_task_status_id
      );
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF l_task_status_id IS NULL THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_status');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --------
    --------  Task Priority
    --------
    IF (l_task_priority_name = fnd_api.g_miss_char AND l_task_priority_id = fnd_api.g_miss_num) THEN
      l_task_priority_id  := task_rec.task_priority_id;
    ELSIF(l_task_priority_name = fnd_api.g_miss_char AND l_task_priority_id <> fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_priority(
        p_task_priority_id           => l_task_priority_id
      , p_task_priority_name         => NULL
      , x_return_status              => x_return_status
      , x_task_priority_id           => l_task_priority_id
      );
    ELSIF(l_task_priority_name <> fnd_api.g_miss_char AND l_task_priority_id = fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_task_priority(
        p_task_priority_id           => NULL
      , p_task_priority_name         => l_task_priority_name
      , x_return_status              => x_return_status
      , x_task_priority_id           => l_task_priority_id
      );
    ELSE
      jtf_task_utl.validate_task_priority(
        p_task_priority_id           => l_task_priority_id
      , p_task_priority_name         => l_task_priority_name
      , x_return_status              => x_return_status
      , x_task_priority_id           => l_task_priority_id
      );
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --------
    --------  Asssigned By Name
    --------
    IF (l_assigned_by_name = fnd_api.g_miss_char AND l_assigned_by_id = fnd_api.g_miss_num) THEN
      l_assigned_by_id  := task_rec.assigned_by_id;
    ELSIF     (l_assigned_by_name = fnd_api.g_miss_char)
          AND (l_assigned_by_id <> fnd_api.g_miss_num OR l_assigned_by_id IS NULL) THEN
      jtf_task_utl.validate_assigned_by(
        p_assigned_by_id             => l_assigned_by_id
      , p_assigned_by_name           => NULL
      , x_return_status              => x_return_status
      , x_assigned_by_id             => l_assigned_by_id
      );
    ELSIF     (l_assigned_by_name <> fnd_api.g_miss_char OR l_assigned_by_name IS NULL)
          AND (l_assigned_by_id = fnd_api.g_miss_num) THEN
      jtf_task_utl.validate_assigned_by(
        p_assigned_by_id             => NULL
      , p_assigned_by_name           => l_assigned_by_name
      , x_return_status              => x_return_status
      , x_assigned_by_id             => l_assigned_by_id
      );
    ELSE
      jtf_task_utl.validate_assigned_by(
        p_assigned_by_id             => l_assigned_by_id
      , p_assigned_by_name           => l_assigned_by_name
      , x_return_status              => x_return_status
      , x_assigned_by_id             => l_assigned_by_id
      );
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -----------
    -----------  Customer Id
    -----------
    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (
           p_customer_id <> fnd_api.g_miss_num
        OR p_customer_id IS NULL
        OR p_customer_number <> fnd_api.g_miss_char
        OR p_customer_number IS NULL
       ) THEN
      SELECT DECODE(p_customer_id, fnd_api.g_miss_num, NULL, p_customer_id)
        INTO l_customer_id
        FROM DUAL;

      SELECT DECODE(p_customer_number, fnd_api.g_miss_char, NULL, p_customer_number)
        INTO l_customer_number
        FROM DUAL;

      jtf_task_utl.validate_party(
        p_party_id                   => l_customer_id
      , p_party_number               => l_customer_number
      , x_party_id                   => l_customer_id
      , x_return_status              => x_return_status
      );
    ELSE
      l_customer_id  := task_rec.customer_id;
    END IF;

    -----------
    -----------  Address Id.
    -----------
    IF (p_address_id <> fnd_api.g_miss_num OR p_address_number <> fnd_api.g_miss_char) THEN
      SELECT DECODE(p_address_id, fnd_api.g_miss_num, NULL, p_address_id)
        INTO l_address_id
        FROM DUAL;

      SELECT DECODE(p_address_number, fnd_api.g_miss_char, NULL, p_address_number)
        INTO l_address_number
        FROM DUAL;

      jtf_task_utl.validate_party_site(
        p_party_site_id              => l_address_id
      , p_party_site_number          => l_address_number
      , x_party_site_id              => l_address_id
      , x_return_status              => x_return_status
      );
    ELSE
      l_address_id  := task_rec.address_id;
    END IF;

    -----------
    -----------  Customer Account Info.
    -----------
    IF (p_cust_account_id <> fnd_api.g_miss_num OR p_cust_account_number <> fnd_api.g_miss_char) THEN
      SELECT DECODE(p_cust_account_id, fnd_api.g_miss_num, NULL, p_cust_account_id)
        INTO l_cust_account_id
        FROM DUAL;

      SELECT DECODE(p_cust_account_number, fnd_api.g_miss_char, NULL, p_cust_account_number)
        INTO l_cust_account_number
        FROM DUAL;

      jtf_task_utl.validate_cust_account(
        p_cust_account_id            => l_cust_account_id
      , p_cust_account_number        => l_cust_account_number
      , x_cust_account_id            => l_cust_account_id
      , x_return_status              => x_return_status
      );
    ELSE
      l_cust_account_id  := task_rec.cust_account_id;
    END IF;

    /*  removing fix for bug #1628560
          ----
          ----  Cross-validate customer/address/account
          ----
          jtf_task_utl.validate_party_site_acct (
       p_party_id => l_customer_id,
       p_party_site_id => l_address_id,
       p_cust_account_id => l_cust_account_id,
       x_return_status => x_return_status
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success)
          THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
          END IF;

    */    ----
          ----  Planned Dates
          ----
    l_planned_start_date       := task_rec.planned_start_date;
    l_planned_end_date         := task_rec.planned_end_date;
    jtf_task_utl.validate_dates
                 (
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PLANNED')
    , p_start_date                 => l_planned_start_date
    , p_end_date                   => l_planned_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ----
    ----  scheduled Dates
    ----
    l_scheduled_start_date     := task_rec.scheduled_start_date;
    l_scheduled_end_date       := task_rec.scheduled_end_date;
    jtf_task_utl.validate_dates
                 (
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'SCHEDULED')
    , p_start_date                 => l_scheduled_start_date
    , p_end_date                   => l_scheduled_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ----
    ----  Actual Dates
    ----
    l_actual_start_date        := task_rec.actual_start_date;
    l_actual_end_date          := task_rec.actual_end_date;
    jtf_task_utl.validate_dates
                 (
      p_date_tag                   => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'ACTUAL')
    , p_start_date                 => l_actual_start_date
    , p_end_date                   => l_actual_end_date
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --------
    --------  Validate source object details
    --------
    l_source_object_type_code  := task_rec.source_object_type_code;
    l_source_object_id         := task_rec.source_object_id;
    l_source_object_name       := task_rec.source_object_name;

    --- Added the if condition. It will validate only if the field is being updated, else it will be ignored.
    IF p_source_object_type_code = fnd_api.g_miss_char AND p_source_object_id = fnd_api.g_miss_num THEN
       --Commented out for minipatch 401
      --ELSE
      jtf_task_utl.validate_source_object(
        p_object_code                => l_source_object_type_code
      , p_object_id                  => l_source_object_id
      , p_object_name                => l_source_object_name
      , x_return_status              => x_return_status
      );
    END IF;

    ---- Also, since we are denormalizing the source_object_name,
    ---- on every update, the source_object_name is updated to the
    ---- proper source_object_name.
    l_source_object_name       :=
      jtf_task_utl.check_truncation
                         (
        p_object_name                => jtf_task_utl.get_owner(
                                          task_rec.source_object_type_code
                                        , task_rec.source_object_id
                                        )
      );

    ---- Commented out by lokumar as part of bug#5741482
    ---- source_object_name is ultimately updated at PKG level
    /*
     update jtf_tasks_b
     set source_object_name = l_source_object_name
     where task_id =  l_task_id ;
     */
    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ----------
    ----------  Validate duration
    ----------
    l_duration                 := task_rec.DURATION;
    l_duration_uom             := task_rec.duration_uom;

    ----------
    ----------  Do not validate if either duration or duration_uom
    ----------  is missing, to fix bug #1893801
    ----------
    IF (
            l_duration <> fnd_api.g_miss_num
        AND l_duration IS NOT NULL
        AND l_duration_uom <> fnd_api.g_miss_char
        AND l_duration_uom IS NOT NULL
       ) THEN
      jtf_task_utl.validate_effort
                 (
        p_tag                        => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'DURATION')
      , p_tag_uom                    => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'DURATION_UOM')
      , p_effort                     => l_duration
      , p_effort_uom                 => l_duration_uom
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    ----------
    ----------  Validate actual_effort
    ----------
    l_actual_effort            := task_rec.actual_effort;
    l_actual_effort_uom        := task_rec.actual_effort_uom;
    jtf_task_utl.validate_effort
                  (
      p_tag                        => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'ACTUAL_EFFORT')
    , p_tag_uom                    => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'ACTUAL_EFFORT_UOM')
    , p_effort                     => l_actual_effort
    , p_effort_uom                 => l_actual_effort_uom
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ----------
    ----------  Validate planned_effort
    ----------
    l_planned_effort           := task_rec.planned_effort;
    l_planned_effort_uom       := task_rec.planned_effort_uom;
    jtf_task_utl.validate_effort
                  (
      p_tag                        => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PLANNED_EFFORT')
    , p_tag_uom                    => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                      , 'PLANNED_EFFORT_UOM')
    , p_effort                     => l_planned_effort
    , p_effort_uom                 => l_planned_effort_uom
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate percentage complete
    -------
    IF (p_percentage_complete <> fnd_api.g_miss_num OR p_percentage_complete IS NULL) THEN
      IF p_percentage_complete < 0 OR p_percentage_complete > 100 THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_PCT_COMPLETE');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_percentage_complete      := task_rec.percentage_complete;

    -------
    ------- Validate private flag
    -------
    IF p_private_flag <> fnd_api.g_miss_char THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'PRIVATE_FLAG')
      , p_flag_value                 => p_private_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_private_flag  := p_private_flag;
    ELSE
      l_private_flag  := task_rec.private_flag;
    END IF;

    -------
    ------- Validate publish flag
    -------
    IF p_publish_flag <> fnd_api.g_miss_char OR p_publish_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'PUBLISH_FLAG')
      , p_flag_value                 => p_publish_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_publish_flag  := p_publish_flag;
    ELSE
      l_publish_flag  := task_rec.publish_flag;
    END IF;

    -------
    ------- Validate restrict closure flag
    -------
    IF p_restrict_closure_flag <> fnd_api.g_miss_char OR p_restrict_closure_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'RESTRICT_CLOSURE_FLAG')
      , p_flag_value                 => p_restrict_closure_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_restrict_closure_flag  := p_restrict_closure_flag;
    ELSE
      l_restrict_closure_flag  := task_rec.restrict_closure_flag;
    END IF;

    -------
    ------- Validate multibooked flag
    -------
    IF p_multi_booked_flag <> fnd_api.g_miss_char OR p_multi_booked_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'MULTIBOOKED_FLAG')
      , p_flag_value                 => p_multi_booked_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_multi_booked_flag  := p_multi_booked_flag;
    ELSE
      l_multi_booked_flag  := task_rec.multi_booked_flag;
    END IF;

    -------
    ------- Validate milestone flag
    -------
    IF p_milestone_flag <> fnd_api.g_miss_char OR p_milestone_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'MILESTONE_FLAG')
      , p_flag_value                 => p_milestone_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_milestone_flag  := p_milestone_flag;
    ELSE
      l_milestone_flag  := task_rec.milestone_flag;
    END IF;

    -------
    ------- Validate holiday flag
    -------
    IF p_holiday_flag <> fnd_api.g_miss_char OR p_holiday_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'HOILDAY_FLAG')
      , p_flag_value                 => p_holiday_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_holiday_flag  := p_holiday_flag;
    ELSE
      l_holiday_flag  := task_rec.holiday_flag;
    END IF;

    -------
    ------- Validate palm flag
    -------
    IF p_palm_flag <> fnd_api.g_miss_char THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'PALM_FLAG')
      , p_flag_value                 => p_palm_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_palm_flag  := p_palm_flag;
    ELSE
      l_palm_flag  := task_rec.palm_flag;
    END IF;

    -------
    ------- Validate wince flag
    -------
    IF p_wince_flag <> fnd_api.g_miss_char OR p_wince_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'WINCE_FLAG')
      , p_flag_value                 => p_wince_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_wince_flag  := p_wince_flag;
    ELSE
      l_wince_flag  := task_rec.wince_flag;
    END IF;

    -------
    ------- Validate laptop flag
    -------
    IF p_laptop_flag <> fnd_api.g_miss_char OR p_laptop_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'LAPTOP_FLAG')
      , p_flag_value                 => p_laptop_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_laptop_flag  := p_laptop_flag;
    ELSE
      l_laptop_flag  := task_rec.laptop_flag;
    END IF;

    -------
    ------- Validate billable flag
    -------
    IF p_billable_flag <> fnd_api.g_miss_char THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'BILLABLE_FLAG')
      , p_flag_value                 => p_billable_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_billable_flag  := p_billable_flag;
    ELSE
      l_billable_flag  := task_rec.billable_flag;
    END IF;

    --------
    --------  Task Timezone
    --------
    IF (p_timezone_name = fnd_api.g_miss_char AND p_timezone_id = fnd_api.g_miss_num) THEN
      l_timezone_id  := task_rec.timezone_id;
    ELSIF     p_timezone_name = fnd_api.g_miss_char
          AND (p_timezone_id <> fnd_api.g_miss_num OR p_timezone_id IS NULL) THEN
      jtf_task_utl.validate_timezones(
        p_timezone_id                => p_timezone_id
      , p_timezone_name              => NULL
      , x_return_status              => x_return_status
      , x_timezone_id                => l_timezone_id
      );
    ELSIF     (p_timezone_name <> fnd_api.g_miss_char OR p_timezone_name IS NULL)
          AND p_timezone_id = fnd_api.g_miss_num THEN
      jtf_task_utl.validate_timezones(
        p_timezone_id                => NULL
      , p_timezone_name              => p_timezone_name
      , x_return_status              => x_return_status
      , x_timezone_id                => l_timezone_id
      );
    ELSE
      jtf_task_utl.validate_timezones(
        p_timezone_id                => p_timezone_id
      , p_timezone_name              => p_timezone_name
      , x_return_status              => x_return_status
      , x_timezone_id                => l_timezone_id
      );
    END IF;

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -------
    ------- Validate soft bound flag
    -------
    IF p_soft_bound_flag <> fnd_api.g_miss_char OR p_soft_bound_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'SOFTBOUND_FLAG')
      , p_flag_value                 => p_soft_bound_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_soft_bound_flag  := p_soft_bound_flag;
    ELSE
      l_soft_bound_flag  := task_rec.soft_bound_flag;
    END IF;

    -------
    ------- Validate device1 flag
    -------
    IF p_device1_flag <> fnd_api.g_miss_char OR p_device1_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'DEVICE1_FLAG')
      , p_flag_value                 => p_device1_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_device1_flag  := p_device1_flag;
    ELSE
      l_device1_flag  := task_rec.device1_flag;
    END IF;

    -------
    ------- Validate device2 flag
    -------
    IF p_device2_flag <> fnd_api.g_miss_char OR p_device2_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'DEVICE2_FLAG')
      , p_flag_value                 => p_device2_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_device2_flag  := p_device2_flag;
    ELSE
      l_device2_flag  := task_rec.device2_flag;
    END IF;

    -------
    ------- Validate device3 flag
    -------
    IF p_device3_flag <> fnd_api.g_miss_char OR p_device3_flag IS NULL THEN
      jtf_task_utl.validate_flag
               (
        p_flag_name                  => jtf_task_utl.get_translated_lookup
                                                                    ('JTF_TASK_TRANSLATED_MESSAGES'
                                        , 'DEVICE3_FLAG')
      , p_flag_value                 => p_device3_flag
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_device3_flag  := p_device3_flag;
    ELSE
      l_device3_flag  := task_rec.device3_flag;
    END IF;

    -------
    ------- Validate Notification
    -------
    IF (
           p_notification_period <> fnd_api.g_miss_num
        OR p_notification_period IS NULL
        OR p_notification_period_uom <> fnd_api.g_miss_char
        OR p_notification_period_uom IS NULL
        OR p_notification_flag <> fnd_api.g_miss_char
        OR p_notification_flag IS NULL
       ) THEN
      /*        IF (  p_notification_period <> fnd_api.g_miss_num
               OR p_notification_period IS NULL)
            THEN
          l_notification_period := p_notification_period;
            ELSE
          l_notification_period := task_rec.notification_period;
            END IF;

            IF (  p_notification_period_uom <> fnd_api.g_miss_char
               OR p_notification_period_uom IS NULL)
            THEN
          l_notification_period_uom := p_notification_period_uom;
            ELSE
          l_notification_period_uom := task_rec.notification_period_uom;
            END IF;

            IF (  p_notification_flag <> fnd_api.g_miss_char
               OR p_notification_flag IS NULL)
            THEN
          l_notification_flag := p_notification_flag;
            ELSE
          l_notification_flag := task_rec.notification_flag;
            END IF;
      */
      l_notification_flag        := task_rec.notification_flag;
      l_notification_period      := task_rec.notification_period;
      l_notification_period_uom  := task_rec.notification_period_uom;
      jtf_task_utl.validate_notification(
        p_notification_flag          => l_notification_flag
      , p_notification_period        => l_notification_period
      , p_notification_period_uom    => l_notification_period_uom
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('JTF', 'INVALID_NOTIFICATION');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      l_notification_flag        := task_rec.notification_flag;
      l_notification_period      := task_rec.notification_period;
      l_notification_period_uom  := task_rec.notification_period_uom;
    END IF;

    -----------
    -----------   Validate alarm
    -----------
    IF (
           p_alarm_start <> fnd_api.g_miss_num
        OR p_alarm_start_uom <> fnd_api.g_miss_char
        OR p_alarm_on <> fnd_api.g_miss_char
        OR p_alarm_count <> fnd_api.g_miss_num
        OR p_alarm_fired_count <> fnd_api.g_miss_num
        OR p_alarm_interval <> fnd_api.g_miss_num
        OR p_alarm_interval_uom <> fnd_api.g_miss_char
        OR p_alarm_start IS NULL
        OR p_alarm_start_uom IS NULL
        OR p_alarm_on IS NULL
        OR p_alarm_count IS NULL
        OR p_alarm_fired_count IS NULL
        OR p_alarm_interval IS NULL
        OR p_alarm_interval_uom IS NULL
       ) THEN
      l_alarm_start         := task_rec.alarm_start;
      l_alarm_start_uom     := task_rec.alarm_start_uom;
      l_alarm_on            := task_rec.alarm_on;
      l_alarm_interval      := task_rec.alarm_interval;
      l_alarm_interval_uom  := task_rec.alarm_interval_uom;
      l_alarm_count         := task_rec.alarm_count;
      l_alarm_fired_count   := task_rec.alarm_fired_count;
      jtf_task_utl.validate_alarm(
        p_alarm_start                => l_alarm_start
      , p_alarm_start_uom            => l_alarm_start_uom
      , p_alarm_on                   => l_alarm_on
      , p_alarm_count                => l_alarm_count
      , p_alarm_interval             => l_alarm_interval
      , p_alarm_interval_uom         => l_alarm_interval_uom
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('JTF', 'INVALID_ALARM_PARAM');
        fnd_msg_pub.ADD;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_alarm_fired_count IS NOT NULL THEN
        IF l_alarm_fired_count > l_alarm_count THEN
          fnd_message.set_name('JTF', 'INVALID_ALARM_PARAM');
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    ELSE
      l_alarm_start         := task_rec.alarm_start;
      l_alarm_start_uom     := task_rec.alarm_start_uom;
      l_alarm_on            := task_rec.alarm_on;
      l_alarm_interval      := task_rec.alarm_interval;
      l_alarm_interval_uom  := task_rec.alarm_interval_uom;
      l_alarm_count         := task_rec.alarm_count;
      l_alarm_fired_count   := task_rec.alarm_fired_count;
    END IF;

    l_owner_id                 := task_rec.owner_id;
    l_owner_type_code          := task_rec.owner_type_code;

    -----
    -----  Validate Owner
    -----
    IF (
           p_owner_type_code <> fnd_api.g_miss_char
        OR p_owner_type_code IS NULL
        OR p_owner_id IS NULL
        OR p_owner_id <> fnd_api.g_miss_num
        OR p_owner_type_name IS NULL
        OR p_owner_type_name <> fnd_api.g_miss_char
       ) THEN
      l_owner_type_name  := p_owner_type_name;
      jtf_task_utl.validate_task_owner(
        p_owner_type_name            => l_owner_type_name
      , p_owner_type_code            => l_owner_type_code
      , p_owner_id                   => l_owner_id
      , x_return_status              => x_return_status
      , x_owner_id                   => l_owner_id
      , x_owner_type_code            => l_owner_type_code
      );
    END IF;

    ----------
    ----------   Validate costs
    ----------
    l_costs                    := task_rec.costs;
    l_currency_code            := task_rec.currency_code;

    IF (
           p_costs <> fnd_api.g_miss_num
        OR p_costs IS NULL
        OR p_currency_code IS NULL
        OR p_currency_code <> fnd_api.g_miss_char
       ) THEN
      l_costs          := task_rec.costs;
      l_currency_code  := task_rec.currency_code;
      jtf_task_utl.validate_costs(p_costs => l_costs, p_currency_code => l_currency_code
      , x_return_status              => x_return_status);

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    ---------------
    ---------------  Bound mode code.
    ---------------
    l_bound_mode_code          := task_rec.bound_mode_code;

    IF l_bound_mode_code IS NOT NULL AND l_bound_mode_code <> fnd_api.g_miss_char THEN
      y  := jtf_task_utl.validate_lookup('JTF_TASK_BOUND_MODE_CODE', l_bound_mode_code, NULL);

      IF y = FALSE THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    ---------------
    ---------------  Validate date_selected
    ---------------
    l_date_selected            := task_rec.date_selected;

    IF l_date_selected IS NOT NULL AND l_date_selected <> fnd_api.g_miss_char THEN
      IF l_date_selected NOT IN('P', 'S', 'A', 'D') THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    ---------------
    ---------------  Validate owner_status_id
    ---------------
   /* moved  code to pvt package for bug # 8574559 */

    ------- Validating the parent task id
    -------
    IF    (p_parent_task_id IS NOT NULL AND p_parent_task_id <> fnd_api.g_miss_num)
       OR (p_parent_task_number IS NOT NULL AND p_parent_task_number <> fnd_api.g_miss_char) THEN
      SELECT DECODE(p_parent_task_id, fnd_api.g_miss_num, NULL, p_parent_task_id)
        INTO l_parent_task_id
        FROM DUAL;

      SELECT DECODE(p_parent_task_number, fnd_api.g_miss_char, NULL, p_parent_task_number)
        INTO l_parent_task_number
        FROM DUAL;

      jtf_task_utl.validate_task(
        p_task_id                    => l_parent_task_id
      , p_task_number                => l_parent_task_number
      , x_task_id                    => l_parent_task_id
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    --  Bug 2786689 : Fixing  Cyclic Task Issue : Removed code to
    --  PVT api.
    ELSE
      l_parent_task_id  := p_parent_task_id;
    END IF;

    l_reason_code              := task_rec.reason_code;
    jtf_tasks_pvt.update_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => l_task_id
    , p_task_name                  => l_task_name
    , p_task_type_id               => l_task_type_id
    , p_description                => task_rec.description
    , p_task_status_id             => l_task_status_id
    , p_task_priority_id           => l_task_priority_id
    , p_owner_type_code            => l_owner_type_code
    , p_owner_id                   => l_owner_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_assigned_by_id             => l_assigned_by_id
    , p_customer_id                => l_customer_id
    , p_cust_account_id            => l_cust_account_id
    , p_address_id                 => l_address_id
    , p_planned_start_date         => l_planned_start_date
    , p_planned_end_date           => l_planned_end_date
    , p_scheduled_start_date       => l_scheduled_start_date
    , p_scheduled_end_date         => l_scheduled_end_date
    , p_actual_start_date          => l_actual_start_date
    , p_actual_end_date            => l_actual_end_date
    , p_timezone_id                => l_timezone_id
    , p_source_object_type_code    => l_source_object_type_code
    , p_source_object_id           => l_source_object_id
    , p_source_object_name         => l_source_object_name
    , p_duration                   => l_duration
    , p_duration_uom               => l_duration_uom
    , p_planned_effort             => l_planned_effort
    , p_planned_effort_uom         => l_planned_effort_uom
    , p_actual_effort              => l_actual_effort
    , p_actual_effort_uom          => l_actual_effort_uom
    , p_percentage_complete        => l_percentage_complete
    , p_reason_code                => l_reason_code
    , p_private_flag               => l_private_flag
    , p_publish_flag               => l_publish_flag
    , p_restrict_closure_flag      => l_restrict_closure_flag
    , p_multi_booked_flag          => l_multi_booked_flag
    , p_milestone_flag             => l_milestone_flag
    , p_holiday_flag               => l_holiday_flag
    , p_billable_flag              => l_billable_flag
    , p_bound_mode_code            => l_bound_mode_code
    , p_soft_bound_flag            => l_soft_bound_flag
    , p_workflow_process_id        => task_rec.workflow_process_id
    , p_notification_flag          => l_notification_flag
    , p_notification_period        => l_notification_period
    , p_notification_period_uom    => l_notification_period_uom
    , p_parent_task_id             => l_parent_task_id
    , p_alarm_start                => l_alarm_start
    , p_alarm_start_uom            => l_alarm_start_uom
    , p_alarm_on                   => l_alarm_on
    , p_alarm_count                => l_alarm_count
    , p_alarm_fired_count          => l_alarm_fired_count
    , p_alarm_interval             => l_alarm_interval
    , p_alarm_interval_uom         => l_alarm_interval_uom
    , p_palm_flag                  => l_palm_flag
    , p_wince_flag                 => l_wince_flag
    , p_laptop_flag                => l_laptop_flag
    , p_device1_flag               => l_device1_flag
    , p_device2_flag               => l_device2_flag
    , p_device3_flag               => l_device3_flag
    , p_costs                      => l_costs
    , p_currency_code              => l_currency_code
    , p_escalation_level           => p_escalation_level
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_attribute1                 => task_rec.attribute1
    , p_attribute2                 => task_rec.attribute2
    , p_attribute3                 => task_rec.attribute3
    , p_attribute4                 => task_rec.attribute4
    , p_attribute5                 => task_rec.attribute5
    , p_attribute6                 => task_rec.attribute6
    , p_attribute7                 => task_rec.attribute7
    , p_attribute8                 => task_rec.attribute8
    , p_attribute9                 => task_rec.attribute9
    , p_attribute10                => task_rec.attribute10
    , p_attribute11                => task_rec.attribute11
    , p_attribute12                => task_rec.attribute12
    , p_attribute13                => task_rec.attribute13
    , p_attribute14                => task_rec.attribute14
    , p_attribute15                => task_rec.attribute15
    , p_attribute_category         => task_rec.attribute_category
    , p_date_selected              => task_rec.date_selected
    , p_category_id                => p_category_id
    , p_show_on_calendar           => p_show_on_calendar
    , p_owner_status_id            => p_owner_status_id
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
    ,
      --         p_task_confirmation_status => 'N',  -- confirmation status should be changed in jtf_tasks_confirmations apis
      p_task_confirmation_status   => fnd_api.g_miss_char
    , p_task_confirmation_counter  => fnd_api.g_miss_num
    , p_task_split_flag            => task_rec.task_split_flag
    , p_change_mode                => jtf_task_repeat_appt_pvt.g_one
    , p_free_busy_type             => g_free_busy_type
    , p_child_position             => task_rec.child_position
    , p_child_sequence_num         => task_rec.child_sequence_num
    , p_location_id                => task_rec.location_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

          -----------
          ----------- Call Internal API hooks.
          -----------
    /*  jtf_tasks_iuhk.update_task_post (x_return_status);


          IF NOT (x_return_status = fnd_api.g_ret_sts_success)
          THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE fnd_api.g_exc_unexpected_error;
          END IF;

    */  -----------
          -----------
          -----------

    -- Added by SBARAT on 21/10/2005 for bug# 4670385
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO update_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO update_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END;

  -- Old Version
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_TASK';
  BEGIN
    SAVEPOINT delete_task_pub2;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    delete_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_true
    , p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => p_task_id
    , p_task_number                => p_task_number
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
      ROLLBACK TO delete_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      ROLLBACK TO delete_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- New Version
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
  ) IS
    l_api_version CONSTANT NUMBER                         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                   := 'DELETE_TASK';
    l_task_id              jtf_tasks_b.task_id%TYPE       := p_task_id;
    l_task_number          jtf_tasks_b.task_number%TYPE   := p_task_number;
  BEGIN
    SAVEPOINT delete_task_pub;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF (l_task_id IS NULL AND l_task_number IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      jtf_task_utl.validate_task(
        p_task_id                    => l_task_id
      , p_task_number                => l_task_number
      , x_task_id                    => l_task_id
      , x_return_status              => x_return_status
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    jtf_tasks_pvt.delete_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_object_version_number      => p_object_version_number
    , p_task_id                    => l_task_id
    , p_delete_future_recurrences  => p_delete_future_recurrences
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_enable_workflow            => p_enable_workflow
    , p_abort_workflow             => p_abort_workflow
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
      ROLLBACK TO delete_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      ROLLBACK TO delete_task_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE export_query_task   --  INPUT VARIABLES

                             --    p_file_name           - file name for output of export file, always
                             --          placed in /sqlcom/out directory
                             --
                             --    possible query variables which are named after fields in jtf_tasks_v
                             --    p_task_number         - query by task number
                             --    p_task_id
                             --    p_task_name
                             --    p_description
                             --    p_task_status_name
                             --    p_task_status_id
                             --    p_task_priority_name
                             --    p_task_priority_id
                             --    p_owner_type_code
                             --    p_owner_id
                             --    p_assigned_name
                             --    p_assigned_by_id
                             --    p_address_id
                             --    p_planned_start_date
                             --    p_planned_end_date
                             --    p_scheduled_start_date
                             --    p_scheduled_end_date
                             --    p_actual_start_date
                             --    p_actual_end_date
                             --    p_object_type_code
                             --    p_object_name
                             --    p_percentage_complete
                             --    p_reason_code
                             --    p_private_flag
                             --    p_restrict_closure_flag
                             --    p_multi_booked_flag
                             --    p_milestone_flag
                             --    p_holiday_flag
                             --    p_workflow_process_id
                             --    p_notification_flag
                             --    p_parent_task_id
                             --    p_alarm_on
                             --    p_alarm_count
                             --    p_alarm_fired_count
                             --
                             --    p_ref_object_id         -- referenced object id
                             --    p_ref_object_type_code      -- referenced object type code
                             --
                             --    p_sort_data           -- sort data structucture based on sort date
                             --    p_start_pointer         -- return records starting at this number
                             --    p_rec_wanted          -- return the next 'n' records from start_pointer
                             --    p_show_all          -- return all the records (value Y or N), overrides start_pointer, rec_wanted
                             --    p_query_or_next_code        -- run query or retrieve records from previous query (value Q/N)
                             --
                             --    OUTPUT values
                             --    x_task_table          -- pl/sql table of records
                             --    x_total_retrieved         -- total number of records selected by query
                             --    x_total_returned        -- number of records returned in pl/sql table
  (
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
  ) IS
    l_api_version CONSTANT NUMBER         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)   := 'EXPORT_QUERY_TASK';
    l_return_status        VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    export_query_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_validate_level             => p_validate_level
    , p_file_name                  => p_file_name
    , p_task_number                => p_task_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_description                => p_description
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_assigned_name              => p_assigned_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_address_id                 => p_address_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_customer_id                => p_customer_id
    , p_customer_name              => p_customer_name
    , p_customer_number            => p_customer_number
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_object_type_code           => p_object_type_code
    , p_object_name                => p_object_name
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
    , x_object_version_number      => x_object_version_number
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
  END export_query_task;

  PROCEDURE export_query_task   --  INPUT VARIABLES

                             --    p_file_name           - file name for output of export file, always
                             --          placed in /sqlcom/out directory
                             --
                             --    possible query variables which are named after fields in jtf_tasks_v
                             --    p_task_number         - query by task number
                             --    p_task_id
                             --    p_task_name
                             --    p_description
                             --    p_task_status_name
                             --    p_task_status_id
                             --    p_task_priority_name
                             --    p_task_priority_id
                             --    p_owner_type_code
                             --    p_owner_id
                             --    p_assigned_name
                             --    p_assigned_by_id
                             --    p_address_id
                             --    p_planned_start_date
                             --    p_planned_end_date
                             --    p_scheduled_start_date
                             --    p_scheduled_end_date
                             --    p_actual_start_date
                             --    p_actual_end_date
                             --    p_object_type_code
                             --    p_object_name
                             --    p_percentage_complete
                             --    p_reason_code
                             --    p_private_flag
                             --    p_restrict_closure_flag
                             --    p_multi_booked_flag
                             --    p_milestone_flag
                             --    p_holiday_flag
                             --    p_workflow_process_id
                             --    p_notification_flag
                             --    p_parent_task_id
                             --    p_alarm_on
                             --    p_alarm_count
                             --    p_alarm_fired_count
                             --
                             --    p_ref_object_id         -- referenced object id
                             --    p_ref_object_type_code      -- referenced object type code
                             --
                             --    p_sort_data           -- sort data structucture based on sort date
                             --    p_start_pointer         -- return records starting at this number
                             --    p_rec_wanted          -- return the next 'n' records from start_pointer
                             --    p_show_all          -- return all the records (value Y or N), overrides start_pointer, rec_wanted
                             --    p_query_or_next_code        -- run query or retrieve records from previous query (value Q/N)
                             --
                             --    OUTPUT values
                             --    x_task_table          -- pl/sql table of records
                             --    x_total_retrieved         -- total number of records selected by query
                             --    x_total_returned        -- number of records returned in pl/sql table
  (
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
  ) IS
    l_api_version CONSTANT NUMBER                        := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                  := 'EXPORT_QUERY_TASK';
    l_return_status        VARCHAR2(1)                   := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    v_task_table           jtf_tasks_pub.task_table_type;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    query_task(
      p_api_version
    , p_init_msg_list
    , p_validate_level
    , p_task_number
    , p_task_id
    , p_task_name
    , p_description
    , p_task_type_name
    , p_task_type_id
    , p_task_status_name
    , p_task_status_id
    , p_task_priority_name
    , p_task_priority_id
    , p_owner_type_code
    , p_owner_id
    , p_assigned_name
    , p_assigned_by_id
    , p_address_id
    , p_owner_territory_id
    , p_customer_id
    , p_customer_name
    , p_customer_number
    , p_cust_account_number
    , p_cust_account_id
    , p_planned_start_date
    , p_planned_end_date
    , p_scheduled_start_date
    , p_scheduled_end_date
    , p_actual_start_date
    , p_actual_end_date
    , p_object_type_code
    , p_object_name
    , p_source_object_id
    , p_percentage_complete
    , p_reason_code
    , p_private_flag
    , p_restrict_closure_flag
    , p_multi_booked_flag
    , p_milestone_flag
    , p_holiday_flag
    , p_workflow_process_id
    , p_notification_flag
    , p_parent_task_id
    , p_alarm_on
    , p_alarm_count
    , p_alarm_fired_count
    , p_ref_object_id
    , p_ref_object_type_code
    , p_sort_data
    , p_start_pointer
    , p_rec_wanted
    , p_show_all
    , p_query_or_next_code
    , v_task_table
    , x_total_retrieved
    , x_total_returned
    , x_return_status
    , x_msg_count
    , x_msg_data
    , x_object_version_number
    , p_location_id
    );
    export_file(
      p_api_version
    , p_init_msg_list
    , p_validate_level
    , p_file_name
    , v_task_table
    , x_return_status
    , x_msg_count
    , x_msg_data
    , x_object_version_number
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
  END export_query_task;

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
  ) IS
    l_path        CONSTANT VARCHAR2(30)   := '/sqlcom/out';   -- directory for file output
    l_api_version CONSTANT NUMBER         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)   := 'EXPORT_FILE';
    l_return_status        VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_tbl_count            NUMBER         := p_task_table.COUNT;
  BEGIN   -- export_file
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- required parameters to control records returned

    -- p_file_name must not be null
    IF (p_file_name IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_EXP_FILE_NAME_NULL');
      RAISE fnd_api.g_exc_error;
    END IF;

    -- l_table_count must be > 0, or no records are in the table
    IF (l_tbl_count = 0) THEN
      fnd_message.set_name('JTF', 'JTF_TK_EXP_TABLE_EMPTY');
      RAISE fnd_api.g_exc_error;
    END IF;

    jtf_tasks_pvt.export_file(l_path, p_file_name, p_task_table, x_return_status, x_msg_count
    , x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END export_file;

  PROCEDURE val_task(
    v_task_id     IN OUT NOCOPY jtf_tasks_v.task_id%TYPE
  , p_task_number IN            jtf_tasks_v.task_number%TYPE
  , p_task_name   IN            jtf_tasks_v.task_name%TYPE
  ) IS
    CURSOR c_task_number IS
      SELECT task_id
        FROM jtf_tasks_b
       WHERE task_number = p_task_number;

    CURSOR c_task_name IS
      -- Fix for Bug # 2516412 - changed the view jtf_tasks_v to jtf_tasks_vl
      SELECT NULL
        FROM jtf_tasks_vl
       WHERE task_name = p_task_name AND NVL(deleted_flag, 'N') = 'N';

    v_dummy VARCHAR2(1);
  BEGIN
    IF (p_task_number IS NOT NULL) THEN
      OPEN c_task_number;

      FETCH c_task_number
       INTO v_task_id;

      IF c_task_number%NOTFOUND THEN
        CLOSE c_task_number;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_NUMBER');
        fnd_message.set_token('P_TASK_NUMBER', p_task_number);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_task_number;
      END IF;
    ELSIF(p_task_name IS NOT NULL) THEN
      OPEN c_task_name;

      FETCH c_task_name
       INTO v_dummy;

      IF c_task_name%NOTFOUND THEN
        CLOSE c_task_name;

        fnd_message.set_name('JTF', 'JTF_TASK_INV_TK_NAME');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_task_name;
      END IF;
    END IF;
  END;

  PROCEDURE val_task_id(p_task_id IN jtf_tasks_v.task_id%TYPE) IS
    CURSOR c_task_id IS
      SELECT NULL
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    v_dummy VARCHAR2(1);
  BEGIN
    IF (p_task_id IS NOT NULL) THEN
      OPEN c_task_id;

      FETCH c_task_id
       INTO v_dummy;

      IF c_task_id%NOTFOUND THEN
        CLOSE c_task_id;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
        fnd_message.set_token('P_TASK_ID', p_task_id);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_task_id;
      END IF;
    END IF;
  END val_task_id;

  PROCEDURE val_dates(p_start IN DATE, p_end IN DATE) IS
  BEGIN
    IF (p_start IS NOT NULL) AND(p_end IS NOT NULL) THEN
      IF (p_end < p_start) THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_DATES');
        fnd_message.set_token('P_DATE_TAG', p_start);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END val_dates;

  PROCEDURE val_assigned(
    v_assigned_by_id IN OUT NOCOPY jtf_tasks_v.assigned_by_id%TYPE
  , p_assigned_name  IN            jtf_tasks_v.assigned_by_name%TYPE
  ) IS
    CURSOR c_assigned_by_name IS
      SELECT user_id assigned_by_id
        FROM fnd_user
       WHERE user_name = p_assigned_name
         AND NVL(end_date, SYSDATE) >= SYSDATE
         AND NVL(start_date, SYSDATE) <= SYSDATE;
  BEGIN
    IF (p_assigned_name IS NOT NULL) THEN
      OPEN c_assigned_by_name;

      FETCH c_assigned_by_name
       INTO v_assigned_by_id;

      IF c_assigned_by_name%NOTFOUND THEN
        CLOSE c_assigned_by_name;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_ASSIGNED_NAME');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_assigned_by_name;
      END IF;
    END IF;
  END;

  PROCEDURE val_object_type(
    v_object_type_code IN OUT NOCOPY jtf_tasks_v.source_object_type_code%TYPE
  , p_object_name      IN            jtf_tasks_v.source_object_name%TYPE
  ) IS
    CURSOR c_object_type_name IS
      SELECT object_code
        FROM jtf_objects_vl
       WHERE NAME = p_object_name
         AND NVL(end_date_active, SYSDATE) >= SYSDATE
         AND NVL(start_date_active, SYSDATE) <= SYSDATE;
  BEGIN
    IF (p_object_name IS NOT NULL) THEN
      OPEN c_object_type_name;

      FETCH c_object_type_name
       INTO v_object_type_code;

      IF c_object_type_name%NOTFOUND THEN
        CLOSE c_object_type_name;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
        fnd_message.set_token('P_object_type_code', p_object_name);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_object_type_name;
      END IF;
    END IF;
  END;

  PROCEDURE val_customer(
    p_customer_id     IN OUT NOCOPY jtf_tasks_v.customer_id%TYPE
  , p_customer_name   IN            jtf_tasks_v.customer_name%TYPE
  , p_customer_number IN            jtf_tasks_v.customer_number%TYPE
  ) IS
    CURSOR c1 IS
      SELECT party_id
        FROM hz_parties
       WHERE party_name = p_customer_name;

    CURSOR c2 IS
      SELECT party_id
        FROM hz_parties
       WHERE party_number = p_customer_number;
  BEGIN
    IF (p_customer_number IS NOT NULL) THEN
      OPEN c2;

      FETCH c2
       INTO p_customer_id;

      IF c2%NOTFOUND THEN
        CLOSE c2;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_CUST_NUMBER');
        fnd_message.set_token('P_customer_number', p_customer_number);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c2;
      END IF;
    ELSIF(p_customer_name IS NOT NULL) THEN
      OPEN c1;

      FETCH c1
       INTO p_customer_id;

      IF c1%NOTFOUND THEN
        CLOSE c1;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_CUST_NAME');
        fnd_message.set_token('P_customer_name', p_customer_name);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c1;
      END IF;
    END IF;
  END val_customer;

  PROCEDURE val_cust_account(
    p_cust_account_id     IN OUT NOCOPY jtf_tasks_v.cust_account_id%TYPE
  , p_cust_account_number IN            jtf_tasks_v.cust_account_number%TYPE
  ) IS
    CURSOR c1 IS
      SELECT cust_account_id
        FROM hz_cust_accounts
       WHERE account_number = p_cust_account_number;
  BEGIN
    IF (p_cust_account_number IS NOT NULL) THEN
      OPEN c1;

      FETCH c1
       INTO p_cust_account_id;

      IF c1%NOTFOUND THEN
        CLOSE c1;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_CUST_ACCT_NUM');
        fnd_message.set_token('P_CUST_ACCOUNT_NUMBER', p_cust_account_number);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c1;
      END IF;
    END IF;
  END val_cust_account;

  PROCEDURE val_priority(
    v_task_priority_id   IN OUT NOCOPY jtf_tasks_v.task_priority_id%TYPE
  , p_task_priority_name IN            jtf_tasks_v.task_priority%TYPE
  ) IS
    CURSOR c_task_priority_name IS
      SELECT task_priority_id
        FROM jtf_task_priorities_vl
       WHERE NAME = p_task_priority_name
         AND NVL(end_date_active, SYSDATE) >= SYSDATE
         AND NVL(start_date_active, SYSDATE) <= SYSDATE;
  BEGIN
    IF (p_task_priority_name IS NOT NULL) THEN
      OPEN c_task_priority_name;

      FETCH c_task_priority_name
       INTO v_task_priority_id;

      IF c_task_priority_name%NOTFOUND THEN
        CLOSE c_task_priority_name;

        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_PRIORITY_NAME');
        fnd_message.set_token('P_TASK_PRIORITY_NAME', p_task_priority_name);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        CLOSE c_task_priority_name;
      END IF;
    END IF;
  END val_priority;

  PROCEDURE query_task   --  possible query variables which are named after fields in jtf_tasks_v

                      --    p_task_number     - query by task number
                      --    p_task_id
                      --    p_task_name
                      --    p_description
                      --    p_task_status_name
                      --    p_task_status_id
                      --    p_task_priority_name
                      --    p_task_priority_id
                      --    p_owner_type_code
                      --    p_owner_id
                      --    p_assigned_name
                      --    p_assigned_by_id
                      --    p_address_id
                      --    p_planned_start_date
                      --    p_planned_end_date
                      --    p_scheduled_start_date
                      --    p_scheduled_end_date
                      --    p_actual_start_date
                      --    p_actual_end_date
                      --    p_object_type_code
                      --    p_object_name
                      --    p_percentage_complete
                      --    p_reason_code
                      --    p_private_flag
                      --    p_restrict_closure_flag
                      --    p_multi_booked_flag
                      --    p_milestone_flag
                      --    p_holiday_flag
                      --    p_workflow_process_id
                      --    p_notification_flag
                      --    p_parent_task_id
                      --    p_alarm_on
                      --    p_alarm_count
                      --    p_alarm_fired_count
                      --
                      --    p_ref_object_id     -- referenced object id
                      --    p_ref_object_type_code    -- referenced object type code
                      --
                      --    p_sort_data     -- sort data structucture based on sort date

  --    p_query_or_next_code    -- run query or retrieve records from previous query (value Q/N)
                      --
                      --    OUTPUT values
                      --    x_task_table      -- pl/sql table of records
                      --    x_total_retrieved     -- total number of records selected by query
                      --    x_total_returned      -- number of records returned in pl/sql table
  (
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
  ) IS
    l_api_version CONSTANT NUMBER         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)   := 'QUERY_TASK';
    l_return_status        VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
  BEGIN
    SAVEPOINT query_task_pub1;
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    query_task(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_validate_level             => p_validate_level
    , p_task_number                => p_task_number
    , p_task_id                    => p_task_id
    , p_task_name                  => p_task_name
    , p_description                => p_description
    , p_task_type_name             => p_task_type_name
    , p_task_type_id               => p_task_type_id
    , p_task_status_name           => p_task_status_name
    , p_task_status_id             => p_task_status_id
    , p_task_priority_name         => p_task_priority_name
    , p_task_priority_id           => p_task_priority_id
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_assigned_name              => p_assigned_name
    , p_assigned_by_id             => p_assigned_by_id
    , p_address_id                 => p_address_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_customer_id                => p_customer_id
    , p_customer_name              => p_customer_name
    , p_customer_number            => p_customer_number
    , p_cust_account_number        => p_cust_account_number
    , p_cust_account_id            => p_cust_account_id
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_object_type_code           => p_object_type_code
    , p_object_name                => p_object_name
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
    , x_object_version_number      => x_object_version_number
    , p_location_id                => NULL
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO query_task_pub1;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO query_task_pub1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO query_task_pub1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_task;

  PROCEDURE query_task   --  possible query variables which are named after fields in jtf_tasks_v

                      --    p_task_number     - query by task number
                      --    p_task_id
                      --    p_task_name
                      --    p_description
                      --    p_task_status_name
                      --    p_task_status_id
                      --    p_task_priority_name
                      --    p_task_priority_id
                      --    p_owner_type_code
                      --    p_owner_id
                      --    p_assigned_name
                      --    p_assigned_by_id
                      --    p_address_id
                      --    p_planned_start_date
                      --    p_planned_end_date
                      --    p_scheduled_start_date
                      --    p_scheduled_end_date
                      --    p_actual_start_date
                      --    p_actual_end_date
                      --    p_object_type_code
                      --    p_object_name
                      --    p_percentage_complete
                      --    p_reason_code
                      --    p_private_flag
                      --    p_restrict_closure_flag
                      --    p_multi_booked_flag
                      --    p_milestone_flag
                      --    p_holiday_flag
                      --    p_workflow_process_id
                      --    p_notification_flag
                      --    p_parent_task_id
                      --    p_alarm_on
                      --    p_alarm_count
                      --    p_alarm_fired_count
                      --
                      --    p_ref_object_id     -- referenced object id
                      --    p_ref_object_type_code    -- referenced object type code
                      --
                      --    p_sort_data     -- sort data structucture based on sort date

  --    p_query_or_next_code    -- run query or retrieve records from previous query (value Q/N)
                      --
                      --    OUTPUT values
                      --    x_task_table      -- pl/sql table of records
                      --    x_total_retrieved     -- total number of records selected by query
                      --    x_total_returned      -- number of records returned in pl/sql table
  (
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
  ) IS
    l_api_version CONSTANT NUMBER                                     := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                               := 'QUERY_TASK';
    l_return_status        VARCHAR2(1)                                := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    v_task_id              jtf_tasks_v.task_id%TYPE                   := p_task_id;
    v_task_type_id         jtf_tasks_v.task_type_id%TYPE              := p_task_type_id;
    v_task_status_id       jtf_tasks_v.task_status_id%TYPE            := p_task_status_id;
    v_object_type_code     jtf_tasks_v.source_object_type_code%TYPE   := p_object_type_code;
    v_task_priority_id     jtf_tasks_v.task_priority_id%TYPE          := p_task_priority_id;
    v_customer_id          jtf_tasks_v.customer_id%TYPE               := p_customer_id;
    v_cust_account_id      jtf_tasks_v.cust_account_id%TYPE           := p_cust_account_id;
    v_assigned_by_id       jtf_tasks_v.assigned_by_id%TYPE;
    l_type                 VARCHAR2(10);
  BEGIN
    SAVEPOINT query_task_pub2;
    x_return_status   := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- required parameters to control records returned

    -- p_ref_object_type_code or p_ref object_id is not null then both must exist
    IF (p_ref_object_type_code IS NOT NULL) OR(p_ref_object_id IS NOT NULL) THEN
      IF (p_ref_object_type_code IS NULL) OR(p_ref_object_id IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_OBJECT_TYPE_ID_RQD');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- p_query_or_next_code should be Q or N
    IF (p_query_or_next_code NOT IN('Q', 'N')) OR(p_query_or_next_code IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_QRY_NXT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- p_show_all should be Y or N
    IF (p_show_all NOT IN('Y', 'N')) OR(p_show_all IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_SHOW_ALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_show_all = 'N') THEN
      IF (p_start_pointer IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_STRT_PTR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_rec_wanted IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_REC_WANT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- validate query parameters
    IF (v_task_id IS NULL) THEN
      val_task(v_task_id, p_task_number, p_task_name);
    END IF;

    IF (v_object_type_code IS NULL) THEN
      val_object_type(v_object_type_code, p_object_name);
    END IF;

    IF (v_task_type_id IS NULL AND p_task_type_name IS NOT NULL) THEN
      jtf_task_utl.validate_task_type(p_task_type_id, p_task_type_name, l_return_status
      , v_task_type_id);

      IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF (p_task_status_id IS NULL AND p_task_status_name IS NOT NULL) THEN
      IF v_task_type_id = '22' THEN
        l_type  := 'ESCALATION';
      ELSE
        l_type  := 'TASK';
      END IF;

      jtf_task_utl.validate_task_status(p_task_status_id, p_task_status_name, l_type
      , l_return_status, v_task_status_id);

      IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF (v_task_priority_id IS NULL) THEN
      val_priority(v_task_priority_id, p_task_priority_name);
    END IF;

    v_assigned_by_id  := p_assigned_by_id;

    IF (v_assigned_by_id IS NOT NULL) THEN
      val_assigned(v_assigned_by_id, p_assigned_name);
    END IF;

    IF (p_customer_id IS NULL) AND(p_customer_name IS NOT NULL OR p_customer_number IS NOT NULL) THEN
      val_customer(v_customer_id, p_customer_name, p_customer_number);
    END IF;

    IF (p_cust_account_id IS NULL) AND(p_cust_account_number IS NOT NULL) THEN
      val_cust_account(v_cust_account_id, p_cust_account_number);
    END IF;

    val_dates(p_planned_start_date, p_planned_end_date);
    val_dates(p_scheduled_start_date, p_scheduled_end_date);
    val_dates(p_actual_start_date, p_actual_end_date);
    -- private flag
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'PRIVATE_FLAG')
    , p_private_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- restrict closure
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'RESTRICT_CLOSURE_FLAG')
    , p_restrict_closure_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- multi_booked_flag
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'MULTIBOOKED_FLAG')
    , p_multi_booked_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- milestone_flag
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'MILESTONE_FLAG')
    , p_milestone_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- holiday_flag
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'HOLIDAY_FLAG')
    , p_holiday_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- notification_flag
    jtf_task_utl.validate_flag(
      l_api_name
    , p_init_msg_list
    , l_return_status
    , jtf_task_utl.get_translated_lookup('JTF_TASK_TRANSLATED_MESSAGES', 'NOTIFICATION_FLAG')
    , p_notification_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --call private api to execute the fetch
    jtf_tasks_pvt.query_task(
      0
    , v_task_id
    , p_description
    , v_task_type_id
    , v_task_status_id
    , p_task_priority_id
    , p_owner_type_code
    , p_owner_id
    , p_assigned_by_id
    , p_address_id
    , p_owner_territory_id
    , p_customer_id
    , p_cust_account_id
    , p_planned_start_date
    , p_planned_end_date
    , p_scheduled_start_date
    , p_scheduled_end_date
    , p_actual_start_date
    , p_actual_end_date
    , v_object_type_code
    , p_source_object_id
    , p_percentage_complete
    , p_reason_code
    , p_private_flag
    , p_restrict_closure_flag
    , p_multi_booked_flag
    , p_milestone_flag
    , p_holiday_flag
    , p_workflow_process_id
    , p_notification_flag
    , p_parent_task_id
    , p_alarm_on
    , p_alarm_count
    , p_alarm_fired_count
    , p_ref_object_id
    , p_ref_object_type_code
    , p_task_name
    , p_sort_data
    , p_start_pointer
    , p_rec_wanted
    , p_show_all
    , p_query_or_next_code
    , x_task_table
    , x_total_retrieved
    , x_total_returned
    , x_return_status
    , x_msg_count
    , x_msg_data
    , p_location_id
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO query_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO query_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO query_task_pub2;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_task;

  PROCEDURE query_next_task   --  INPUT VARIABLES

                           --  p_file_name         - file name for output of export file, always
                           --              placed in /sqlcom/out directory
                           --
                           --  p_task_id        -- current task id
                           --  p_query_type       -- values Dependency or Date for type of query

  --The following parameters only used if p_query_type is date
                           --  p_date_type        -- date type, values scheduled, planned, actual
                           --  p_date_start_or_end      -- use start or end date of current task values start/end
                           --  p_owner_id       -- query owner_id from jtf_tasks_v
                           --  p_owner_type_code      -- query owner_type_code from jtf_tasks_v
                           --  p_assigned_by        -- assigned_by

  --  p_sort_data         -- sort data structucture based on sort date
                           --  p_start_pointer       -- return records starting at this number
                           --  p_rec_wanted        -- return the next 'n' records from start_pointer
                           --  p_show_all        -- return all the records (value Y or N), overrides start_pointer, rec_wanted
                           --  p_query_or_next_code      -- run query or retrieve records from previous query (value Q/N)
                           --
                           --  OUTPUT values
                           --  x_task_table        -- pl/sql table of records
                           --  x_total_retrieved       -- total number of records selected by query
                           --  x_total_returned      -- number of records returned in pl/sql table
  (
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
  ) IS
    l_api_version CONSTANT NUMBER         := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)   := 'QUERY_NEXT_TASK';
    l_return_status        VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_query_type           VARCHAR2(20)   := UPPER(p_query_type);
    l_date_type            VARCHAR2(20)   := UPPER(p_date_type);
    l_date_start_or_end    VARCHAR2(6)    := UPPER(p_date_start_or_end);
  BEGIN
    SAVEPOINT query_next_task;
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- required parameters to control records returned

    -- p_query_or_next_code should be Q or N
    IF (p_query_or_next_code NOT IN('Q', 'N')) OR(p_query_or_next_code IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_QRY_NXT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- p_show_all should be Y or N
    IF (p_show_all NOT IN('Y', 'N')) OR(p_show_all IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_SHOW_ALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_show_all = 'N') THEN
      IF (p_start_pointer IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_STRT_PTR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_rec_wanted IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_REC_WANT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- parameters to control querying
    IF (l_query_type NOT IN('DEPENDENCY', 'ASSIGNED', 'OWNER')) THEN
      fnd_message.set_name('JTF', 'JTF_TK_QRY_NXT_INV_QRY_TYP');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    ELSE
      -- check date_type and date_start_or_end
      IF (l_date_type NOT IN('SCHEDULED', 'PLANNED', 'ACTUAL')) THEN
        fnd_message.set_name('JTF', 'JTF_TK_QRY_NXT_INV_DT_TYPE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_date_start_or_end NOT IN('END', 'START')) THEN
        fnd_message.set_name('JTF', 'JTF_TK_QRY_NXT_INV_STRT_END_DT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_query_type = 'ASSIGNED') THEN
        IF (p_assigned_by IS NULL) THEN
          fnd_message.set_name('JTF', 'JTF_TK_QRY_NXT_NUL_ASGND_BY');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF(l_query_type = 'OWNER') THEN
        IF (p_owner_type_code IS NULL OR p_owner_id IS NULL) THEN
          fnd_message.set_name('JTF', 'JTF_TK_QRY_NXT_NUL_OWNER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    -- validate query parameters

    -- task id should not be null
    IF (p_task_id IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- check for valid task_id
    val_task_id(p_task_id);
    --call private api to execute the fetch
    jtf_tasks_pvt.query_next_task(
      0
    , p_task_id
    , UPPER(p_query_type)
    , UPPER(p_date_type)
    , UPPER(p_date_start_or_end)
    , p_owner_id
    , p_owner_type_code
    , p_assigned_by
    , p_sort_data
    , p_start_pointer
    , p_rec_wanted
    , p_show_all
    , p_query_or_next_code
    , x_task_table
    , x_total_retrieved
    , x_total_returned
    , x_return_status
    , x_msg_count
    , x_msg_data
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO query_next_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END query_next_task;

  -----------
  -----------   Copy Task
  -----------
  -----------
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
  ) IS
    l_api_version     CONSTANT NUMBER                                             := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                                       := 'COPY_TASK';
    l_source_task_id           jtf_tasks_b.task_id%TYPE                         := p_source_task_id;
    l_target_task_id           jtf_tasks_b.task_id%TYPE                         := p_target_task_id;
    l_task_number              jtf_tasks_b.task_id%TYPE                     := p_source_task_number;
    l_dependency_id            jtf_task_depends.dependency_id%TYPE;
    l_task_assignment_id       jtf_task_all_assignments.task_assignment_id%TYPE;
    l_resource_req_id          jtf_task_rsc_reqs.resource_req_id%TYPE;
    l_task_reference_id        jtf_task_references_b.task_reference_id%TYPE;
    l_task_date_id             jtf_task_dates.task_date_id%TYPE;
    l_recurrence_rule_id       jtf_task_recur_rules.recurrence_rule_id%TYPE;
    l_task_rec                 jtf_task_recurrences_pub.task_details_rec;
    l_output_dates_counter     NUMBER;

    CURSOR c_task IS
      SELECT tk.laptop_flag
           , tk.device1_flag
           , tk.device2_flag
           , tk.device3_flag
           , tk.template_id
           , tk.template_group_id
           , tk.currency_code
           , tk.costs
           , tk.task_type_id
           , tk.task_status_id
           , tk.task_priority_id
           , tk.owner_id
           , tk.owner_type_code
           , tk.assigned_by_id
           , tk.cust_account_id
           , tk.customer_id
           , tk.address_id
           , tk.location_id
           , tk.planned_start_date
           , tk.planned_end_date
           , tk.scheduled_start_date
           , tk.scheduled_end_date
           , tk.actual_start_date
           , tk.actual_end_date
           , tk.source_object_type_code
           , tk.timezone_id
           , tk.source_object_id
           , tk.source_object_name
           , tk.DURATION
           , tk.duration_uom
           , tk.planned_effort
           , tk.planned_effort_uom
           , tk.actual_effort
           , tk.actual_effort_uom
           , tk.percentage_complete
           , tk.reason_code
           , tk.private_flag
           , tk.publish_flag
           , tk.restrict_closure_flag
           , tk.multi_booked_flag
           , tk.milestone_flag
           , tk.holiday_flag
           , tk.billable_flag
           , tk.bound_mode_code
           , tk.soft_bound_flag
           , tk.workflow_process_id
           , tk.notification_flag
           , tk.notification_period
           , tk.notification_period_uom
           , tk.parent_task_id
           , tk.recurrence_rule_id
           , tk.alarm_start
           , tk.alarm_start_uom
           , tk.alarm_on
           , tk.alarm_count
           , tk.alarm_fired_count
           , tk.alarm_interval
           , tk.alarm_interval_uom
           , tk.deleted_flag
           , tk.palm_flag
           , tk.wince_flag
           , tk.task_name
           , tk.description
           , tk.date_selected
           , tk.attribute1
           , tk.attribute2
           , tk.attribute3
           , tk.attribute4
           , tk.attribute5
           , tk.attribute6
           , tk.attribute7
           , tk.attribute8
           , tk.attribute9
           , tk.attribute10
           , tk.attribute11
           , tk.attribute12
           , tk.attribute13
           , tk.attribute14
           , tk.attribute15
           , tk.attribute_category
           , NVL(tka.category_id, NULL) category_id
           , NVL(tka.show_on_calendar, NULL) show_on_calendar
           , NVL(tka.assignment_status_id, NULL) assignment_status_id
           , tka.free_busy_type free_busy_type
           , tk.entity
        FROM jtf_tasks_vl tk, jtf_task_all_assignments tka
       WHERE tk.task_id = l_source_task_id AND tk.task_id = tka.task_id(+) AND 'OWNER' = tka.assignee_role(+);

    -- Fetch also assignment details for OWNER, if present, as this is
    -- created by the task_create API
    CURSOR c_depends IS
      SELECT dependent_on_task_id
           , dependency_type_code
           , template_flag
           , adjustment_time
           , adjustment_time_uom
           , validated_flag
        FROM jtf_task_depends
       WHERE task_id = l_source_task_id;

    CURSOR c_references IS
      SELECT object_type_code
           , object_name
           , object_id
           , object_details
           , reference_code
           , USAGE
        FROM jtf_task_references_vl
       WHERE task_id = l_source_task_id;

    CURSOR c_dates IS
      SELECT date_type_id
           , date_value
        FROM jtf_task_dates
       WHERE task_id = l_source_task_id;

    CURSOR c_recurs IS
      SELECT occurs_which
           , day_of_week
           , date_of_month
           , occurs_month
           , occurs_uom
           , occurs_every
           , occurs_number
           , start_date_active
           , end_date_active
        FROM jtf_task_recur_rules
       WHERE recurrence_rule_id = l_recurrence_rule_id;

    CURSOR c_rsc_reqs IS
      SELECT task_id
           , resource_type_code
           , required_units
           , enabled_flag
        FROM jtf_task_rsc_reqs
       WHERE task_id = l_source_task_id;

    CURSOR c_assignments IS
      SELECT resource_type_code
           , resource_id
           , actual_effort
           , actual_effort_uom
           , schedule_flag
           , alarm_type_code
           , alarm_contact
           , sched_travel_distance
           , sched_travel_duration
           , sched_travel_duration_uom
           , actual_travel_distance
           , actual_travel_duration
           , actual_travel_duration_uom
           , actual_start_date
           , actual_end_date
           , palm_flag
           , wince_flag
           , laptop_flag
           , device1_flag
           , device2_flag
           , device3_flag
           , resource_territory_id
           , assignment_status_id
           , assignee_role
           , show_on_calendar
           , category_id
           , free_busy_type
        FROM jtf_task_all_assignments
       WHERE task_id = l_source_task_id AND assignee_role = 'ASSIGNEE';

    -- Assignment record for OWNER is created by the task_create API
    CURSOR c1_assignments IS
      SELECT resource_type_code
           , resource_id
           , actual_effort
           , actual_effort_uom
           , schedule_flag
           , alarm_type_code
           , alarm_contact
           , sched_travel_distance
           , sched_travel_duration
           , sched_travel_duration_uom
           , actual_travel_distance
           , actual_travel_duration
           , actual_travel_duration_uom
           , actual_start_date
           , actual_end_date
           , palm_flag
           , wince_flag
           , laptop_flag
           , device1_flag
           , device2_flag
           , device3_flag
           , resource_territory_id
           , assignment_status_id
           , assignee_role
           , show_on_calendar
           , category_id
           , free_busy_type
        FROM jtf_task_all_assignments
       WHERE task_id = l_source_task_id AND assignee_role = 'ASSIGNEE';

    CURSOR c_notes(p_source_object_code IN VARCHAR2) IS
      SELECT jtf_note_id
           , parent_note_id
           , source_object_id
           , source_object_code
           , source_number
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , notes
           , notes_detail
           , note_status
           , entered_by
           , entered_by_name
           , entered_date
           , source_object_meaning
           , note_type
           , note_type_meaning
           , attribute1
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15
           , CONTEXT
           , note_status_meaning
        FROM jtf_notes_vl
       WHERE source_object_id = l_source_task_id AND source_object_code = p_source_object_code;

    CURSOR c_contacts IS
      SELECT task_contact_id
           , contact_id
           , contact_type_code
           , escalation_notify_flag
           , escalation_requester_flag
           , primary_flag
        FROM jtf_task_contacts
       WHERE task_id = l_source_task_id;

    CURSOR c_contact_points(b_contact_id jtf_task_phones.task_contact_id%TYPE) IS
      SELECT phone_id
           , task_phone_id
           , primary_flag
        FROM jtf_task_phones
       WHERE task_contact_id = b_contact_id;

    tasks                      c_task%ROWTYPE;
    depends                    c_depends%ROWTYPE;
    REFERENCE                  c_references%ROWTYPE;
    dates                      c_dates%ROWTYPE;
    recurs                     c_recurs%ROWTYPE;
    rsc_reqs                   c_rsc_reqs%ROWTYPE;
    assignments                c_assignments%ROWTYPE;
    notes                      c_notes%ROWTYPE;
    contacts                   c_contacts%ROWTYPE;
    contact_points             c_contact_points%ROWTYPE;
    l_jtf_note_id              NUMBER;
    l_rowid                    VARCHAR2(20);
    l_note_id                  NUMBER;
    l_source_object_id         NUMBER;
    l_notes_detail             VARCHAR2(32767);
    l_task_contact_id          NUMBER;
    l_task_phone_id            NUMBER;
    l_notes_source_object_code VARCHAR2(50);   -- Added on 31/05/2006 for bug# 5211606
  BEGIN
    SAVEPOINT copy_task;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF l_source_task_id IS NULL THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TASK_ID');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    jtf_task_utl.validate_task(
      x_return_status              => x_return_status
    , p_task_id                    => p_source_task_id
    , p_task_number                => p_source_task_number
    , x_task_id                    => l_source_task_id
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --- copy the main task.
    OPEN c_task;
    FETCH c_task INTO tasks;
    IF c_task%NOTFOUND THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
      fnd_message.set_token('P_TASK_ID', l_source_task_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
      CLOSE c_task;
    END IF;

    ----------------------------------------------------------------------------------------------------------------------------------
    IF (p_resource_id IS NOT NULL AND p_resource_type IS NOT NULL) THEN
      -- Copy task for all the members in a group or a team.
      jtf_tasks_pvt.create_task(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => p_target_task_id
      , p_task_name                  => tasks.task_name
      , p_task_type_id               => tasks.task_type_id
      , p_description                => tasks.description
      , p_task_status_id             => tasks.task_status_id
      , p_task_priority_id           => tasks.task_priority_id
      , p_owner_type_code            => p_resource_type
      , p_owner_id                   => p_resource_id
      , p_assigned_by_id             => tasks.assigned_by_id
      , p_customer_id                => tasks.customer_id
      , p_cust_account_id            => tasks.cust_account_id
      , p_address_id                 => tasks.address_id
      , p_planned_start_date         => tasks.planned_start_date
      , p_planned_end_date           => tasks.planned_end_date
      , p_scheduled_start_date       => tasks.scheduled_start_date
      , p_scheduled_end_date         => tasks.scheduled_end_date
      , p_actual_start_date          => tasks.actual_start_date
      , p_actual_end_date            => tasks.actual_end_date
      , p_timezone_id                => tasks.timezone_id
      , p_source_object_type_code    => tasks.source_object_type_code
      , p_source_object_id           => tasks.source_object_id
      , p_source_object_name         => tasks.source_object_name
      , p_duration                   => tasks.DURATION
      , p_duration_uom               => tasks.duration_uom
      , p_planned_effort             => tasks.planned_effort
      , p_planned_effort_uom         => tasks.planned_effort_uom
      , p_actual_effort              => tasks.actual_effort
      , p_actual_effort_uom          => tasks.actual_effort_uom
      , p_percentage_complete        => tasks.percentage_complete
      , p_reason_code                => tasks.reason_code
      , p_private_flag               => tasks.private_flag
      , p_publish_flag               => tasks.publish_flag
      , p_restrict_closure_flag      => tasks.restrict_closure_flag
      , p_multi_booked_flag          => tasks.multi_booked_flag
      , p_milestone_flag             => tasks.milestone_flag
      , p_holiday_flag               => tasks.holiday_flag
      , p_billable_flag              => tasks.billable_flag
      , p_bound_mode_code            => tasks.bound_mode_code
      , p_soft_bound_flag            => tasks.soft_bound_flag
      , p_notification_flag          => tasks.notification_flag
      , p_notification_period        => tasks.notification_period
      , p_notification_period_uom    => tasks.notification_period_uom
      , p_parent_task_id             => tasks.parent_task_id
      , p_alarm_start                => tasks.alarm_start
      , p_alarm_start_uom            => tasks.alarm_start_uom
      , p_alarm_on                   => tasks.alarm_on
      , p_alarm_count                => tasks.alarm_count
      , p_alarm_interval             => tasks.alarm_interval
      , p_alarm_interval_uom         => tasks.alarm_interval_uom
      , p_palm_flag                  => tasks.palm_flag
      , p_wince_flag                 => tasks.wince_flag
      , p_laptop_flag                => tasks.laptop_flag
      , p_device1_flag               => tasks.device1_flag
      , p_device2_flag               => tasks.device2_flag
      , p_device3_flag               => tasks.device3_flag
      , p_costs                      => tasks.costs
      , p_currency_code              => tasks.currency_code
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => l_target_task_id
      , p_date_selected              => tasks.date_selected
      , p_category_id                => tasks.category_id
      , p_show_on_calendar           => tasks.show_on_calendar
      , p_owner_status_id            => tasks.assignment_status_id
      , p_attribute1                 => tasks.attribute1
      , p_attribute2                 => tasks.attribute2
      , p_attribute3                 => tasks.attribute3
      , p_attribute4                 => tasks.attribute4
      , p_attribute5                 => tasks.attribute5
      , p_attribute6                 => tasks.attribute6
      , p_attribute7                 => tasks.attribute7
      , p_attribute8                 => tasks.attribute8
      , p_attribute9                 => tasks.attribute9
      , p_attribute10                => tasks.attribute10
      , p_attribute11                => tasks.attribute11
      , p_attribute12                => tasks.attribute12
      , p_attribute13                => tasks.attribute13
      , p_attribute14                => tasks.attribute14
      , p_attribute15                => tasks.attribute15
      , p_attribute_category         => tasks.attribute_category
      , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
      , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
      , p_entity                     => tasks.entity
      , p_free_busy_type             => tasks.free_busy_type
      , p_task_confirmation_status   => 'N'
      , p_task_confirmation_counter  => NULL
      , p_task_split_flag            => NULL
      , p_reference_flag             => NULL
      , p_child_position             => NULL
      , p_child_sequence_num         => NULL
      , p_location_id                => tasks.location_id
      , p_template_id                => tasks.template_id
      , p_template_group_id          => tasks.template_group_id
      , p_copied_from_task_id        => l_source_task_id
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --Create notes
      IF fnd_api.to_boolean(p_copy_notes) THEN
        -- Added on 31/05/2006 for bug# 5211606
        IF ((tasks.entity IS NOT NULL) AND(tasks.entity = 'ESCALATION')) THEN
          l_notes_source_object_code  := 'ESC';
        ELSE
          l_notes_source_object_code  := tasks.entity;
        END IF;

        -- Modified on 31/05/2006 for bug# 5211606
        FOR notes_rec IN c_notes(l_notes_source_object_code) LOOP
          jtf_notes_pub.writelobtodata(notes_rec.jtf_note_id, l_notes_detail);

          SELECT jtf_notes_s.NEXTVAL
            INTO l_note_id
            FROM DUAL;

          jtf_notes_pkg.insert_row(
            x_rowid                      => l_rowid
          , x_jtf_note_id                => l_note_id
          , x_source_object_code         => notes_rec.source_object_code
          , x_note_status                => notes_rec.note_status
          , x_entered_by                 => notes_rec.entered_by
          , x_entered_date               => notes_rec.entered_date
          , x_note_type                  => notes_rec.note_type
          , x_attribute1                 => notes_rec.attribute1
          , x_attribute2                 => notes_rec.attribute2
          , x_attribute3                 => notes_rec.attribute3
          , x_attribute4                 => notes_rec.attribute4
          , x_attribute5                 => notes_rec.attribute5
          , x_attribute6                 => notes_rec.attribute6
          , x_attribute7                 => notes_rec.attribute7
          , x_attribute8                 => notes_rec.attribute8
          , x_attribute9                 => notes_rec.attribute9
          , x_attribute10                => notes_rec.attribute10
          , x_attribute11                => notes_rec.attribute11
          , x_attribute12                => notes_rec.attribute12
          , x_attribute13                => notes_rec.attribute13
          , x_attribute14                => notes_rec.attribute14
          , x_attribute15                => notes_rec.attribute15
          , x_context                    => notes_rec.CONTEXT
          , x_parent_note_id             => notes_rec.parent_note_id
          , x_source_object_id           => l_target_task_id
          , x_notes                      => notes_rec.notes
          , x_notes_detail               => l_notes_detail
          , x_creation_date              => notes_rec.creation_date
          , x_created_by                 => notes_rec.created_by
          , x_last_update_date           => notes_rec.last_update_date
          , x_last_updated_by            => notes_rec.last_updated_by
          , x_last_update_login          => notes_rec.last_update_login
          );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF;
    ELSE
      jtf_tasks_pvt.create_task(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => p_target_task_id
      , p_task_name                  => tasks.task_name
      , p_task_type_id               => tasks.task_type_id
      , p_description                => tasks.description
      , p_task_status_id             => tasks.task_status_id
      , p_task_priority_id           => tasks.task_priority_id
      , p_owner_type_code            => tasks.owner_type_code
      , p_owner_id                   => tasks.owner_id
      , p_assigned_by_id             => tasks.assigned_by_id
      , p_customer_id                => tasks.customer_id
      , p_cust_account_id            => tasks.cust_account_id
      , p_address_id                 => tasks.address_id
      , p_planned_start_date         => tasks.planned_start_date
      , p_planned_end_date           => tasks.planned_end_date
      , p_scheduled_start_date       => tasks.scheduled_start_date
      , p_scheduled_end_date         => tasks.scheduled_end_date
      , p_actual_start_date          => tasks.actual_start_date
      , p_actual_end_date            => tasks.actual_end_date
      , p_timezone_id                => tasks.timezone_id
      , p_source_object_type_code    => tasks.source_object_type_code
      , p_source_object_id           => tasks.source_object_id
      , p_source_object_name         => tasks.source_object_name
      , p_duration                   => tasks.DURATION
      , p_duration_uom               => tasks.duration_uom
      , p_planned_effort             => tasks.planned_effort
      , p_planned_effort_uom         => tasks.planned_effort_uom
      , p_actual_effort              => tasks.actual_effort
      , p_actual_effort_uom          => tasks.actual_effort_uom
      , p_percentage_complete        => tasks.percentage_complete
      , p_reason_code                => tasks.reason_code
      , p_private_flag               => tasks.private_flag
      , p_publish_flag               => tasks.publish_flag
      , p_restrict_closure_flag      => tasks.restrict_closure_flag
      , p_multi_booked_flag          => tasks.multi_booked_flag
      , p_milestone_flag             => tasks.milestone_flag
      , p_holiday_flag               => tasks.holiday_flag
      , p_billable_flag              => tasks.billable_flag
      , p_bound_mode_code            => tasks.bound_mode_code
      , p_soft_bound_flag            => tasks.soft_bound_flag
      , p_notification_flag          => tasks.notification_flag
      , p_notification_period        => tasks.notification_period
      , p_notification_period_uom    => tasks.notification_period_uom
      , p_parent_task_id             => tasks.parent_task_id
      , p_alarm_start                => tasks.alarm_start
      , p_alarm_start_uom            => tasks.alarm_start_uom
      , p_alarm_on                   => tasks.alarm_on
      , p_alarm_count                => tasks.alarm_count
      , p_alarm_interval             => tasks.alarm_interval
      , p_alarm_interval_uom         => tasks.alarm_interval_uom
      , p_palm_flag                  => tasks.palm_flag
      , p_wince_flag                 => tasks.wince_flag
      , p_laptop_flag                => tasks.laptop_flag
      , p_device1_flag               => tasks.device1_flag
      , p_device2_flag               => tasks.device2_flag
      , p_device3_flag               => tasks.device3_flag
      , p_costs                      => tasks.costs
      , p_currency_code              => tasks.currency_code
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_id                    => l_target_task_id
      , p_date_selected              => tasks.date_selected
      , p_category_id                => tasks.category_id
      , p_show_on_calendar           => tasks.show_on_calendar
      , p_owner_status_id            => tasks.assignment_status_id
      , p_attribute1                 => tasks.attribute1
      , p_attribute2                 => tasks.attribute2
      , p_attribute3                 => tasks.attribute3
      , p_attribute4                 => tasks.attribute4
      , p_attribute5                 => tasks.attribute5
      , p_attribute6                 => tasks.attribute6
      , p_attribute7                 => tasks.attribute7
      , p_attribute8                 => tasks.attribute8
      , p_attribute9                 => tasks.attribute9
      , p_attribute10                => tasks.attribute10
      , p_attribute11                => tasks.attribute11
      , p_attribute12                => tasks.attribute12
      , p_attribute13                => tasks.attribute13
      , p_attribute14                => tasks.attribute14
      , p_attribute15                => tasks.attribute15
      , p_attribute_category         => tasks.attribute_category
      , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
      , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
      , p_entity                     => tasks.entity
      , p_free_busy_type             => tasks.free_busy_type
      , p_task_confirmation_status   => 'N'
      , p_task_confirmation_counter  => NULL
      , p_task_split_flag            => NULL
      , p_reference_flag             => NULL
      , p_child_position             => NULL
      , p_child_sequence_num         => NULL
      , p_location_id                => tasks.location_id
      , p_template_id                => tasks.template_id
      , p_template_group_id          => tasks.template_group_id
      , p_copied_from_task_id        => l_source_task_id
      );
      x_task_id  := l_target_task_id;

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF c_task%ISOPEN THEN
      CLOSE c_task;
    END IF;

    ------
    ------ Create contact point for the customer
    ------ (where task_contact_id = task_id)
    ------
    FOR contact_points IN c_contact_points(l_source_task_id) LOOP
      jtf_task_phones_pub.create_task_phones(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_contact_id            => l_target_task_id
      , p_phone_id                   => contact_points.phone_id
      , p_primary_flag               => contact_points.primary_flag
      , p_owner_table_name           => 'JTF_TASKS_B'
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_phone_id              => l_task_phone_id
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;

    -------------------------------------------------------------------------------------------------------------------------
    ------
    ------ Create dependencies
    ------
    IF fnd_api.to_boolean(p_copy_task_depends) THEN
      FOR depends IN c_depends LOOP
        jtf_task_dependency_pvt.create_task_dependency(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_target_task_id
        , p_dependent_on_task_id       => depends.dependent_on_task_id
        , p_dependency_type_code       => depends.dependency_type_code
        , p_template_flag              => depends.template_flag
        , p_adjustment_time            => depends.adjustment_time
        , p_adjustment_time_uom        => depends.adjustment_time_uom
        , p_validated_flag             => depends.validated_flag
        , x_dependency_id              => l_dependency_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    END IF;

    ------
    ------ Create Resource Requirements
    ------
    IF fnd_api.to_boolean(p_copy_task_rsc_reqs) THEN
      FOR rsc_reqs IN c_rsc_reqs LOOP
        jtf_task_resources_pub.create_task_rsrc_req(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_target_task_id
        , p_resource_type_code         => rsc_reqs.resource_type_code
        , p_required_units             => rsc_reqs.required_units
        , p_enabled_flag               => rsc_reqs.enabled_flag
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
    END IF;

    -----------------------------------------------------------------------------------------------------
    ---Code added for mass task creation

    ------
    ------ Create Task Assignments
    ------
    IF fnd_api.to_boolean(p_copy_task_assignments) THEN
      jtf_task_utl.g_validate_category  := FALSE;

      IF (p_resource_id IS NOT NULL AND p_resource_type IS NOT NULL) THEN
        FOR assignments IN c1_assignments LOOP
          jtf_task_assignments_pub.create_task_assignment(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , p_task_id                    => l_target_task_id
          , p_resource_type_code         => p_resource_type
          , p_resource_id                => p_resource_id
          , p_resource_territory_id      => assignments.resource_territory_id
          , p_assignment_status_id       => assignments.assignment_status_id
          , p_actual_effort              => assignments.actual_effort
          , p_actual_effort_uom          => assignments.actual_effort_uom
          , p_schedule_flag              => assignments.schedule_flag
          , p_alarm_type_code            => assignments.alarm_type_code
          , p_alarm_contact              => assignments.alarm_contact
          , p_sched_travel_distance      => assignments.sched_travel_duration
          , p_sched_travel_duration      => assignments.sched_travel_duration
          , p_sched_travel_duration_uom  => assignments.sched_travel_duration_uom
          , p_actual_travel_distance     => assignments.actual_travel_distance
          , p_actual_travel_duration     => assignments.actual_travel_duration
          , p_actual_travel_duration_uom => assignments.actual_travel_duration_uom
          , p_actual_start_date          => assignments.actual_start_date
          , p_actual_end_date            => assignments.actual_end_date
          , p_palm_flag                  => assignments.palm_flag
          , p_wince_flag                 => assignments.wince_flag
          , p_laptop_flag                => assignments.laptop_flag
          , p_device1_flag               => assignments.device1_flag
          , p_device2_flag               => assignments.device2_flag
          , p_device3_flag               => assignments.device3_flag
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , x_task_assignment_id         => l_task_assignment_id
          , p_show_on_calendar           => assignments.show_on_calendar
          , p_category_id                => assignments.category_id
          , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
          , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
          , p_object_capacity_id         => NULL
          , p_free_busy_type             => assignments.free_busy_type
          );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      ELSE
        FOR assignments IN c_assignments LOOP
          jtf_task_assignments_pub.create_task_assignment(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , p_task_id                    => l_target_task_id
          , p_resource_type_code         => assignments.resource_type_code
          , p_resource_id                => assignments.resource_id
          , p_resource_territory_id      => assignments.resource_territory_id
          , p_assignment_status_id       => assignments.assignment_status_id
          , p_actual_effort              => assignments.actual_effort
          , p_actual_effort_uom          => assignments.actual_effort_uom
          , p_schedule_flag              => assignments.schedule_flag
          , p_alarm_type_code            => assignments.alarm_type_code
          , p_alarm_contact              => assignments.alarm_contact
          , p_sched_travel_distance      => assignments.sched_travel_duration
          , p_sched_travel_duration      => assignments.sched_travel_duration
          , p_sched_travel_duration_uom  => assignments.sched_travel_duration_uom
          , p_actual_travel_distance     => assignments.actual_travel_distance
          , p_actual_travel_duration     => assignments.actual_travel_duration
          , p_actual_travel_duration_uom => assignments.actual_travel_duration_uom
          , p_actual_start_date          => assignments.actual_start_date
          , p_actual_end_date            => assignments.actual_end_date
          , p_palm_flag                  => assignments.palm_flag
          , p_wince_flag                 => assignments.wince_flag
          , p_laptop_flag                => assignments.laptop_flag
          , p_device1_flag               => assignments.device1_flag
          , p_device2_flag               => assignments.device2_flag
          , p_device3_flag               => assignments.device3_flag
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , x_task_assignment_id         => l_task_assignment_id
          , p_show_on_calendar           => assignments.show_on_calendar
          , p_category_id                => assignments.category_id
          , p_enable_workflow            => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
          , p_abort_workflow             => fnd_profile.VALUE('JTF_TASK_ABORT_PREV_WF')
          , p_object_capacity_id         => NULL
          , p_free_busy_type             => assignments.free_busy_type
          );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF;
    END IF;

    ------
    ------ Create references
    ------
    IF fnd_api.to_boolean(p_copy_task_references) THEN
      FOR REFERENCE IN c_references LOOP
        jtf_task_utl.g_show_error_for_dup_reference  := FALSE;
        jtf_task_references_pvt.create_references(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_target_task_id
        , p_object_type_code           => REFERENCE.object_type_code
        , p_object_name                => REFERENCE.object_name
        , p_object_id                  => REFERENCE.object_id
        , p_object_details             => REFERENCE.object_details
        , p_reference_code             => REFERENCE.reference_code
        , p_usage                      => REFERENCE.USAGE
        , x_return_status              => x_return_status
        , x_msg_data                   => x_msg_data
        , x_msg_count                  => x_msg_count
        , x_task_reference_id          => l_task_reference_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    END IF;

    ------
    ------ Create dates
    ------
    IF fnd_api.to_boolean(p_copy_task_dates) THEN
      FOR dates IN c_dates LOOP
        jtf_task_dates_pvt.create_task_dates(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_target_task_id
        , p_date_type_id               => dates.date_type_id
        , p_date_value                 => dates.date_value
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_date_id               => l_task_date_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;
    END IF;

    ---- if the user wants to create the recurrences, then check if the source task has a valid recurrence_id
    ---- if yes, then get the recurrence rule and pass it to the task while creating the task.
    ---- if no, then error out.

    ---- For recurrences
    IF fnd_api.to_boolean(p_create_recurrences) THEN
      IF fnd_api.to_boolean(p_create_recurrences) THEN
        ---- get the recurrence rule id for the source task
        BEGIN
          SELECT recurrence_rule_id
            INTO l_recurrence_rule_id
            FROM jtf_tasks_b
           WHERE task_id = l_source_task_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
            fnd_message.set_token('P_TASK_ID', l_source_task_id);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          WHEN OTHERS THEN
            fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        IF l_recurrence_rule_id IS NOT NULL THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

          FOR recurs IN c_recurs LOOP
            jtf_task_recurrences_pvt.create_task_recurrence(
              p_api_version                => 1.0
            , p_init_msg_list              => fnd_api.g_false
            , p_commit                     => fnd_api.g_false
            , p_task_id                    => l_target_task_id
            , p_occurs_which               => recurs.occurs_which
            , p_day_of_week                => recurs.day_of_week
            , p_date_of_month              => recurs.date_of_month
            , p_occurs_month               => recurs.occurs_month
            , p_occurs_uom                 => recurs.occurs_uom
            , p_occurs_every               => recurs.occurs_every
            , p_occurs_number              => recurs.occurs_number
            , p_start_date_active          => recurs.start_date_active
            , p_end_date_active            => recurs.end_date_active
            , p_template_flag              => jtf_task_utl.g_no
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , x_recurrence_rule_id         => l_recurrence_rule_id
            , x_task_rec                   => l_task_rec
            , x_output_dates_counter       => l_output_dates_counter
            );

            IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              x_return_status  := fnd_api.g_ret_sts_unexp_error;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END LOOP;
        END IF;
      END IF;
    END IF;

    ------
    ------ Create contacts
    ------
    IF fnd_api.to_boolean(p_copy_task_contacts) THEN
      FOR contacts IN c_contacts LOOP
        jtf_task_contacts_pub.create_task_contacts(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_target_task_id
        , p_contact_id                 => contacts.contact_id
        , p_contact_type_code          => contacts.contact_type_code
        , p_escalation_notify_flag     => contacts.escalation_notify_flag
        , p_escalation_requester_flag  => contacts.escalation_requester_flag
        , p_primary_flag               => contacts.primary_flag
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_contact_id            => l_task_contact_id
        );

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        ------
        ------ Create contact points for each contact
        ------
        IF fnd_api.to_boolean(p_copy_task_contact_points) THEN
          FOR contact_points IN c_contact_points(contacts.task_contact_id) LOOP
            jtf_task_phones_pub.create_task_phones(
              p_api_version                => 1.0
            , p_init_msg_list              => fnd_api.g_false
            , p_commit                     => fnd_api.g_false
            , p_task_contact_id            => l_task_contact_id
            , p_phone_id                   => contact_points.phone_id
            , p_primary_flag               => contact_points.primary_flag
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , x_task_phone_id              => l_task_phone_id
            );

            IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              x_return_status  := fnd_api.g_ret_sts_unexp_error;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;

    --Added by RDESPOTO, updated by TWAN for fixing bug 3756747
    cac_view_util_pvt.create_repeat_collab_details(p_source_task_id, x_task_id);

    IF c_task%ISOPEN THEN
      CLOSE c_task;
    END IF;

    IF c_depends%ISOPEN THEN
      CLOSE c_depends;
    END IF;

    IF c_references%ISOPEN THEN
      CLOSE c_references;
    END IF;

    IF c_dates%ISOPEN THEN
      CLOSE c_dates;
    END IF;

    IF c_recurs%ISOPEN THEN
      CLOSE c_recurs;
    END IF;

    IF c_rsc_reqs%ISOPEN THEN
      CLOSE c_rsc_reqs;
    END IF;

    IF c_assignments%ISOPEN THEN
      CLOSE c_assignments;
    END IF;

    IF c1_assignments%ISOPEN THEN
      CLOSE c1_assignments;
    END IF;

    IF c_contacts%ISOPEN THEN
      CLOSE c_contacts;
    END IF;

    IF c_notes%ISOPEN THEN
      CLOSE c_notes;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO copy_task;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF c_task%ISOPEN THEN
        CLOSE c_task;
      END IF;

      IF c_depends%ISOPEN THEN
        CLOSE c_depends;
      END IF;

      IF c_references%ISOPEN THEN
        CLOSE c_references;
      END IF;

      IF c_dates%ISOPEN THEN
        CLOSE c_dates;
      END IF;

      IF c_recurs%ISOPEN THEN
        CLOSE c_recurs;
      END IF;

      IF c_rsc_reqs%ISOPEN THEN
        CLOSE c_rsc_reqs;
      END IF;

      IF c_assignments%ISOPEN THEN
        CLOSE c_assignments;
      END IF;

      IF c1_assignments%ISOPEN THEN
        CLOSE c1_assignments;
      END IF;

      IF c_contacts%ISOPEN THEN
        CLOSE c_contacts;
      END IF;

      IF c_notes%ISOPEN THEN
        CLOSE c_notes;
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO copy_task;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF c_task%ISOPEN THEN
        CLOSE c_task;
      END IF;

      IF c_depends%ISOPEN THEN
        CLOSE c_depends;
      END IF;

      IF c_references%ISOPEN THEN
        CLOSE c_references;
      END IF;

      IF c_dates%ISOPEN THEN
        CLOSE c_dates;
      END IF;

      IF c_recurs%ISOPEN THEN
        CLOSE c_recurs;
      END IF;

      IF c_rsc_reqs%ISOPEN THEN
        CLOSE c_rsc_reqs;
      END IF;

      IF c_assignments%ISOPEN THEN
        CLOSE c_assignments;
      END IF;

      IF c1_assignments%ISOPEN THEN
        CLOSE c1_assignments;
      END IF;

      IF c_contacts%ISOPEN THEN
        CLOSE c_contacts;
      END IF;

      IF c_notes%ISOPEN THEN
        CLOSE c_notes;
      END IF;
  END copy_task;

  -- Temp Enh. Refactoring Template Code in create_task_from_template proc....
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
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK_FROM_TEMPLATE';
  BEGIN
    SAVEPOINT create_task_from_template_pub1;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- call new version, passing defaults for new functionality
    create_task_from_template(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => fnd_api.g_false
    , p_task_template_group_id     => p_task_template_group_id
    , p_task_template_group_name   => p_task_template_group_name
    , p_owner_type_code            => p_owner_type_code
    , p_owner_id                   => p_owner_id
    , p_source_object_id           => p_source_object_id
    , p_source_object_name         => p_source_object_name
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_details_tbl           => x_task_details_tbl
    , p_assigned_by_id             => p_assigned_by_id
    , p_cust_account_id            => p_cust_account_id
    , p_customer_id                => p_customer_id
    , p_address_id                 => p_address_id
    , p_actual_start_date          => p_actual_start_date
    , p_actual_end_date            => p_actual_end_date
    , p_planned_start_date         => p_planned_start_date
    , p_planned_end_date           => p_planned_end_date
    , p_scheduled_start_date       => p_scheduled_start_date
    , p_scheduled_end_date         => p_scheduled_end_date
    , p_palm_flag                  => p_palm_flag
    , p_wince_flag                 => p_wince_flag
    , p_laptop_flag                => p_laptop_flag
    , p_device1_flag               => p_device1_flag
    , p_device2_flag               => p_device2_flag
    , p_device3_flag               => p_device3_flag
    , p_parent_task_id             => p_parent_task_id
    , p_percentage_complete        => p_percentage_complete
    , p_timezone_id                => p_timezone_id
    , p_actual_effort              => p_actual_effort
    , p_actual_effort_uom          => p_actual_effort_uom
    , p_reason_code                => p_reason_code
    , p_bound_mode_code            => p_bound_mode_code
    , p_soft_bound_flag            => p_soft_bound_flag
    , p_workflow_process_id        => p_workflow_process_id
    , p_owner_territory_id         => p_owner_territory_id
    , p_costs                      => p_costs
    , p_currency_code              => p_currency_code
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
      ROLLBACK TO create_task_from_template_pub1;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_from_template_pub1;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- New Version...
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
  ) IS
    l_api_version     CONSTANT NUMBER                                               := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)                          := 'CREATE_TASK_FROM_TEMPLATE';
    l_task_template_group_info jtf_task_inst_templates_pub.task_template_group_info;
    l_task_template_info_tbl   jtf_task_inst_templates_pub.task_template_info_tbl;
    l_task_contact_points_tbl  jtf_task_inst_templates_pub.task_contact_points_tbl;
    g_task_details_tbl         jtf_task_inst_templates_pub.task_details_tbl;
  BEGIN
    SAVEPOINT create_task_from_template_pub;   -- Fix Bug 2896377
    x_return_status                                    := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    l_task_template_group_info.task_template_group_id  := p_task_template_group_id;
    l_task_template_group_info.owner_type_code         := p_owner_type_code;
    l_task_template_group_info.owner_id                := p_owner_id;
    l_task_template_group_info.source_object_id        := p_source_object_id;
    l_task_template_group_info.source_object_name      := p_source_object_name;
    l_task_template_group_info.assigned_by_id          := p_assigned_by_id;
    l_task_template_group_info.cust_account_id         := p_cust_account_id;
    l_task_template_group_info.customer_id             := p_customer_id;
    l_task_template_group_info.address_id              := p_address_id;
    l_task_template_group_info.location_id             := p_location_id;
    l_task_template_group_info.actual_start_date       := p_actual_start_date;
    l_task_template_group_info.actual_end_date         := p_actual_end_date;
    l_task_template_group_info.planned_start_date      := p_planned_start_date;
    l_task_template_group_info.planned_end_date        := p_planned_end_date;
    l_task_template_group_info.scheduled_start_date    := p_scheduled_start_date;
    l_task_template_group_info.scheduled_end_date      := p_scheduled_end_date;
    l_task_template_group_info.palm_flag               := p_palm_flag;
    l_task_template_group_info.wince_flag              := p_wince_flag;
    l_task_template_group_info.laptop_flag             := p_laptop_flag;
    l_task_template_group_info.device1_flag            := p_device1_flag;
    l_task_template_group_info.device2_flag            := p_device2_flag;
    l_task_template_group_info.device3_flag            := p_device3_flag;
    l_task_template_group_info.parent_task_id          := p_parent_task_id;
    l_task_template_group_info.percentage_complete     := p_percentage_complete;
    l_task_template_group_info.timezone_id             := p_timezone_id;
    l_task_template_group_info.actual_effort           := p_actual_effort;
    l_task_template_group_info.actual_effort_uom       := p_actual_effort_uom;
    l_task_template_group_info.reason_code             := p_reason_code;
    l_task_template_group_info.bound_mode_code         := p_bound_mode_code;
    l_task_template_group_info.soft_bound_flag         := p_soft_bound_flag;
    l_task_template_group_info.workflow_process_id     := p_workflow_process_id;
    l_task_template_group_info.owner_territory_id      := p_owner_territory_id;
    l_task_template_group_info.costs                   := p_costs;
    l_task_template_group_info.currency_code           := p_currency_code;
    l_task_template_group_info.attribute1              := p_attribute1;
    l_task_template_group_info.attribute2              := p_attribute2;
    l_task_template_group_info.attribute3              := p_attribute3;
    l_task_template_group_info.attribute4              := p_attribute4;
    l_task_template_group_info.attribute5              := p_attribute5;
    l_task_template_group_info.attribute6              := p_attribute6;
    l_task_template_group_info.attribute7              := p_attribute7;
    l_task_template_group_info.attribute8              := p_attribute8;
    l_task_template_group_info.attribute9              := p_attribute9;
    l_task_template_group_info.attribute10             := p_attribute10;
    l_task_template_group_info.attribute11             := p_attribute11;
    l_task_template_group_info.attribute12             := p_attribute12;
    l_task_template_group_info.attribute13             := p_attribute13;
    l_task_template_group_info.attribute14             := p_attribute14;
    l_task_template_group_info.attribute15             := p_attribute15;
    l_task_template_group_info.attribute_category      := p_attribute_category;
    l_task_template_group_info.date_selected           := p_date_selected;
    jtf_task_inst_templates_pub.create_task_from_template
                                          (
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_task_template_group_info   => l_task_template_group_info
    , p_task_templates_tbl         => l_task_template_info_tbl
    , p_task_contact_points_tbl    => l_task_contact_points_tbl
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_task_details_tbl           => g_task_details_tbl
    );

    FOR i IN 1 .. g_task_details_tbl.COUNT LOOP
      x_task_details_tbl(i).task_id           := g_task_details_tbl(i).task_id;
      x_task_details_tbl(i).task_template_id  := g_task_details_tbl(i).task_template_id;
      NULL;
    END LOOP;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_from_template_pub;   -- Fix Bug 2896377
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_from_template_pub;   -- Fix Bug 2896377
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE lock_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id               IN            NUMBER
  , p_object_version_number IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_TASK';
    resource_locked        EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_locked, -54);
  BEGIN
    SAVEPOINT lock_tasks_pub;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    jtf_tasks_pkg.lock_row(x_task_id => p_task_id
    , x_object_version_number      => p_object_version_number);
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN resource_locked THEN
      ROLLBACK TO lock_tasks_pub;
      fnd_message.set_name('JTF', 'JTF_TASK_RESOURCE_LOCKED');
      fnd_message.set_token('P_LOCKED_RESOURCE', 'Task');
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO lock_tasks_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_tasks_pub;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  ------
  ------ This procedure updates the Task record with the source object
  ------ details.  In the update_task API the source object details are
  ------ not allowed to be udpated.
  ------
  PROCEDURE update_task_source(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_object_version_number   IN OUT NOCOPY NUMBER
  , p_task_id                 IN            NUMBER
  , p_source_object_type_code IN            VARCHAR2 DEFAULT NULL
  , p_source_object_id        IN            NUMBER DEFAULT NULL
  , p_source_object_name      IN            VARCHAR2 DEFAULT NULL
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_api_version CONSTANT NUMBER                                := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                          := 'UPDATE_TASK_SOURCE';
    l_task_id              NUMBER;
    l_source_object_name   jtf_tasks_b.source_object_name%TYPE;
  BEGIN
    SAVEPOINT update_task_source;
    x_return_status          := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -------
    ------- Check for truncation of source object name
    -------
    l_source_object_name     := jtf_task_utl.check_truncation(p_object_name => p_source_object_name);
    -------
    ------- Validate source object details
    -------
    jtf_task_utl.validate_source_object(
      p_object_code                => p_source_object_type_code
    , p_object_id                  => p_source_object_id
    , p_object_name                => l_source_object_name
    , x_return_status              => x_return_status
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ------
    ------ Update the Task record with the source object details
    ------
    jtf_tasks_pub.lock_task(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_task_id                    => p_task_id
    , p_object_version_number      => p_object_version_number
    , x_return_status              => x_return_status
    , x_msg_data                   => x_msg_data
    , x_msg_count                  => x_msg_count
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    p_object_version_number  := p_object_version_number + 1;

    /*    jtf_tasks_pkg.update_row (
          x_task_id => p_task_id,
          x_object_version_number => p_object_version_number,
          x_source_object_type_code => l_source_object_type_code,
          x_source_object_id => l_source_object_id,
          x_source_object_name => l_source_object_name,
          x_last_update_date => SYSDATE,
          x_last_updated_by => jtf_task_utl.updated_by,
          x_last_update_login => jtf_task_utl.login_id,
      );
    */
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
      ROLLBACK TO update_task_source;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_source;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Function to check parameter length and throw error if length not in allowed limit bug # 3182170 Start
  FUNCTION check_param_length(
    p_task_name    IN VARCHAR2
  , p_message_name IN VARCHAR2 DEFAULT NULL
  , p_length       IN NUMBER DEFAULT 80
  )
    RETURN VARCHAR2 IS
  BEGIN
    IF LENGTH(p_task_name) > p_length THEN
      fnd_message.set_name('JTF', p_message_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      RETURN p_task_name;
    END IF;
  END;

  -- Function to check parameter length and throw error if length not in allowed limit bug # 3182170 End
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
  ) IS
    CURSOR c_task_info(i_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT a.task_id
           , b.object_version_number
        FROM jtf_task_depends a, jtf_tasks_b b
       WHERE a.task_id = i_task_id AND a.task_id = b.task_id
             AND b.task_split_flag = p_task_split_flag;

    -- Cursor for finding all the tasks depend on the master task
    CURSOR c_mass_tasks_info IS
      SELECT     task_id
               , dependent_on_task_id
            FROM jtf_task_depends
      START WITH dependent_on_task_id = p_task_id
      CONNECT BY PRIOR task_id = dependent_on_task_id;

    -- changed the parameter name by SBARAT on 19/01/2006 for bug# 4888496
    CURSOR c_task_validate(p_task_id jtf_tasks_b.task_id%TYPE) IS
      SELECT object_version_number
           , task_split_flag
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    l_api_version      CONSTANT NUMBER                      := 1.0;
    l_api_name         CONSTANT VARCHAR2(30)                := 'DELETE_SPLIT_TASKS';
    p_delete_future_recurrences VARCHAR2(1)                 := 'S';
    l_return_status             VARCHAR2(1)                 := fnd_api.g_ret_sts_success;
    l_msg_data                  VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_ovn                       NUMBER;
    l_task_info                 c_task_info%ROWTYPE;
    l_mass_tasks_info           c_mass_tasks_info%ROWTYPE;
    l_task_id                   jtf_tasks_b.task_id%TYPE;
    task_val                    c_task_validate%ROWTYPE;
  BEGIN
    SAVEPOINT delete_split_tasks_pub;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    OPEN c_task_validate(p_task_id);

    FETCH c_task_validate
     INTO task_val;

    IF c_task_validate%NOTFOUND THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
      fnd_message.set_token('P_TASK_ID', p_task_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    CLOSE c_task_validate;

    IF (p_task_split_flag IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_SPLIT_FLAG_NULL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (task_val.task_split_flag IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_SPLIT_FLAG_NOT_EXIST');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (task_val.task_split_flag <> 'D' OR task_val.task_split_flag <> 'M') THEN
      fnd_message.set_name('JTF', 'JTF_TASK_SPLIT_FLAG_NOT_VALID');
      fnd_message.set_token('P_TASK_ID', p_task_id);
      fnd_message.set_token('P_TASK_SPLIT_FLAG', task_val.task_split_flag);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (task_val.task_split_flag <> p_task_split_flag) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_SPLIT_FLAG');
      fnd_message.set_token('P_TASK_SPLIT_FLAG', p_task_split_flag);
      fnd_message.set_token('P_TASK_ID', p_task_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_task_split_flag = 'D') THEN
      -- find all the tasks depend on the specific task
      OPEN c_task_info(p_task_id);

      FETCH c_task_info
       INTO l_task_info;

      IF c_task_info%NOTFOUND THEN
        RETURN;
      END IF;

      CLOSE c_task_info;

      -- if try_to_reconnect_flag is 'Y', reconnect dependencies then delete task.
      -- if try_to_reconnect_flag is 'N', just delete task.
      IF (p_try_to_reconnect_flag = 'Y') THEN
        jtf_task_dependency_pvt.reconnect_dependency(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , p_task_id                    => l_task_info.task_id
        , p_template_flag              => p_template_flag
        , x_return_status              => x_return_status
        , x_msg_data                   => x_msg_data
        , x_msg_count                  => x_msg_count
        );
      END IF;

      jtf_tasks_pvt.delete_task(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_object_version_number      => l_task_info.object_version_number
      , p_task_id                    => l_task_info.task_id
      , p_delete_future_recurrences  => p_delete_future_recurrences
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );
    -- if task_split_flag is 'M'
    ELSIF(p_task_split_flag = 'M') THEN
      FOR l_mass_tasks_info IN c_mass_tasks_info LOOP
        OPEN c_task_validate(l_mass_tasks_info.dependent_on_task_id);

        FETCH c_task_validate
         INTO task_val;

        CLOSE c_task_validate;

        IF (task_val.object_version_number IS NOT NULL) THEN
          jtf_tasks_pvt.delete_task(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , p_object_version_number      => task_val.object_version_number
          , p_task_id                    => l_mass_tasks_info.dependent_on_task_id
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        OPEN c_task_validate(l_mass_tasks_info.task_id);

        FETCH c_task_validate
         INTO task_val;

        CLOSE c_task_validate;

        IF (task_val.object_version_number IS NOT NULL) THEN
          jtf_tasks_pvt.delete_task(
            p_api_version                => 1.0
          , p_init_msg_list              => fnd_api.g_false
          , p_commit                     => fnd_api.g_false
          , p_object_version_number      => task_val.object_version_number
          , p_task_id                    => l_mass_tasks_info.task_id
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          );

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      END LOOP;

      IF fnd_api.to_boolean(p_commit) THEN
        COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_split_tasks_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      fnd_msg_pub.ADD;
      ROLLBACK TO delete_split_tasks_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

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
  ) IS
    l_task_att_modified_flag number :=1;
    l_task_updated number;
    l_failed_index number :=1;
    l_completed_index number :=1;
    l_last_task number:=0;
    L_TASK_UPDATE_COMPLTED JTF_NUMBER_TABLE;
    l_succ_task_id_list JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_failed_task_id_list JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_failed_reason_list JTF_VARCHAR2_TABLE_2000 := JTF_VARCHAR2_TABLE_2000();
    l_return_status VARCHAR2(100);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_note_return_status VARCHAR2(100);
    l_note_msg_count NUMBER;
    l_note_msg_data VARCHAR2(2000);
    l_note_id NUMBER;
    l_object_version_number number;
    l_miss_char VARCHAR2(1) :='';
    l_new_task_owner_type_code VARCHAR2(30) :=P_NEW_TASK_OWNER_TYPE_CODE;
    l_new_task_owner_id NUMBER :=P_NEW_TASK_OWNER_ID;
    l_new_task_status_id NUMBER :=P_NEW_TASK_STATUS_ID;
    l_note VARCHAR2(2000) := P_NOTE;
    l_update_status NUMBER := 0;
    l_date_selected jtf_tasks_b.date_selected%TYPE :='S';
    l_planned_start_date DATE :=P_NEW_PLANNED_START_DATE;
    l_planned_end_date DATE :=P_NEW_PLANNED_END_DATE;
    l_actual_start_date DATE := P_NEW_ACTUAL_START_DATE;
    l_actual_end_date DATE := P_NEW_ACTUAL_END_DATE;
    l_scheduled_start_date DATE := P_NEW_SCHEDULED_START_DATE;
    l_scheduled_end_date DATE :=P_NEW_SCHEDULED_END_DATE;
    l_new_planned_start_date DATE ;
    l_new_planned_end_date DATE ;
    l_new_actual_start_date DATE;
    l_new_actual_end_date DATE ;
    l_new_scheduled_start_date DATE ;
    l_new_scheduled_end_date DATE;
    l_task_update_required NUMBER :=1;

    cursor c_task_details(l_task_id IN NUMBER) is
      SELECT object_version_number
            , task_number
            , scheduled_start_date
            , scheduled_end_date
            , planned_start_date
            , planned_end_date
            , actual_start_date
            , actual_end_date
        FROM jtf_tasks_b
       WHERE task_id=l_task_id;

    cursor c_Assignment_details(l_task_id IN NUMBER) is
      SELECT object_version_number,task_assignment_id
        FROM jtf_task_assignments
       WHERE task_id=l_task_id;

    task_rec  c_task_details%ROWTYPE;


  BEGIN
      IF l_new_task_owner_id is null THEN
        l_new_task_owner_id:=FND_API.G_MISS_NUM;
      END IF;

      IF l_new_task_status_id is null THEN
        l_new_task_status_id:=FND_API.G_MISS_NUM;
      END IF;

      IF l_new_task_owner_type_code IS NULL THEN
        l_new_task_owner_type_code:=FND_API.G_MISS_CHAR;
      END IF;

      IF l_note IS NULL THEN
        l_note:=FND_API.G_MISS_CHAR;
      END IF;



      l_date_selected:=SUBSTR(fnd_profile.value('JTF_TASK_DEFAULT_DATE_SELECTED'),1,1);
      IF (P_NEW_CALENDAR_END_DATE is not null AND P_NEW_CALENDAR_END_DATE <> FND_API.G_MISS_DATE) THEN
        if l_date_selected='P' then
          l_planned_end_date:=P_NEW_CALENDAR_END_DATE;
        elsif l_date_selected='A' then
          l_actual_end_date:=P_NEW_CALENDAR_END_DATE;
        else
          l_scheduled_end_date:=P_NEW_CALENDAR_END_DATE;
        end if;
      END IF;

      IF (P_NEW_CALENDAR_START_DATE is not null AND P_NEW_CALENDAR_START_DATE <> FND_API.G_MISS_DATE) THEN
        if l_date_selected='P' then
          l_planned_start_date:=P_NEW_CALENDAR_START_DATE;
        elsif l_date_selected='A' then
          l_actual_start_date:=P_NEW_CALENDAR_START_DATE;
        else
          l_scheduled_start_date:=P_NEW_CALENDAR_START_DATE;
        end if;
      END IF;

      --CHECK IF TASK IS MODIFIED
      IF (l_new_task_status_id IS NULL OR l_new_task_status_id = FND_API.G_MISS_NUM)
         AND  (l_new_task_owner_id IS NULL OR l_new_task_owner_id = FND_API.G_MISS_NUM )
         AND  (l_new_task_owner_type_code IS NULL OR l_new_task_owner_type_code = FND_API.G_MISS_CHAR)
         AND  (P_NEW_PLANNED_START_DATE IS NULL OR P_NEW_PLANNED_START_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_PLANNED_END_DATE IS NULL OR P_NEW_PLANNED_END_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_ACTUAL_START_DATE IS NULL OR P_NEW_ACTUAL_START_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_ACTUAL_END_DATE IS NULL OR P_NEW_ACTUAL_END_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_SCHEDULED_START_DATE IS NULL OR P_NEW_SCHEDULED_START_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_SCHEDULED_END_DATE IS NULL OR P_NEW_SCHEDULED_END_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_CALENDAR_START_DATE IS NULL OR P_NEW_CALENDAR_START_DATE = FND_API.G_MISS_DATE)
         AND  (P_NEW_CALENDAR_END_DATE IS NULL OR P_NEW_CALENDAR_END_DATE = FND_API.G_MISS_DATE)
      THEN
        l_task_update_required:=0;
      END IF;

      IF( l_task_update_required=1 or P_REMOVE_ASSIGNMENT_FLAG = 'T') THEN
          -- task attribute are modifed
          -- so we have to call udpate task details
          -- otherwise we dont have to update anything just return back from here
          --OPEN TASK LOOP
          FOR i in 1..P_TASK_ID_LIST.count
          LOOP
            savepoint mass_task_update;
            --update task
            l_update_status:=0;
            l_return_status:= fnd_api.g_ret_sts_success;
            if(l_task_update_required=1) then
              l_return_status:= fnd_api.g_ret_sts_unexp_error;
              open c_task_details(P_TASK_ID_LIST(i));
              fetch c_task_details into task_rec;

              close c_task_details;

              l_new_scheduled_start_date:=l_scheduled_start_date;
              l_new_scheduled_end_date:=l_scheduled_end_date;
              l_new_actual_start_date:=l_actual_start_date;
              l_new_actual_end_date:=l_actual_end_date;
              l_new_planned_start_date:=l_planned_start_date;
              l_new_planned_end_date:=l_planned_end_date;

              IF (l_new_scheduled_start_date is null OR l_new_scheduled_start_date =FND_API.G_MISS_DATE) THEN
                l_new_scheduled_start_date:=task_rec.scheduled_start_date;
              END IF;

              IF (l_new_actual_start_date is null OR l_new_actual_start_date =FND_API.G_MISS_DATE) THEN
                l_new_actual_start_date:=task_rec.actual_start_date;
              END IF;

              IF (l_new_planned_start_date is null OR l_new_planned_start_date =FND_API.G_MISS_DATE) THEN
                l_new_planned_start_date:=task_rec.planned_start_date;
              END IF;

              IF (l_new_scheduled_end_date is null OR l_new_scheduled_end_date =FND_API.G_MISS_DATE) THEN
                l_new_scheduled_end_date:=task_rec.scheduled_end_date;
              END IF;

              IF (l_new_actual_end_date is null OR l_new_actual_end_date =FND_API.G_MISS_DATE) THEN
                l_new_actual_end_date:=task_rec.actual_end_date;
              END IF;

              IF (l_new_planned_end_date is null OR l_new_planned_end_date =FND_API.G_MISS_DATE) THEN
                l_new_planned_end_date:=task_rec.planned_end_date;
              END IF;

              jtf_tasks_pub.update_task(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_TRUE,
                p_commit => FND_API.G_FALSE,
                p_object_version_number =>task_rec.object_version_number,
                p_task_id => P_TASK_ID_LIST(i),
                p_task_status_id => l_new_task_status_id,
                p_owner_type_code => l_new_task_owner_type_code,
                p_owner_id => l_new_task_owner_id,
                p_planned_start_date => l_new_planned_start_date,
                p_planned_end_date	=> l_new_planned_end_date,
                p_scheduled_start_date	=> l_new_scheduled_start_date,
                p_scheduled_end_date	=> l_new_scheduled_end_date,
                p_actual_start_date => l_new_actual_start_date,
                p_actual_end_date => l_new_actual_end_date,
                p_date_selected => l_date_selected,
                p_source_object_type_code => P_NEW_SOURCE_TYPE_CODE,
                p_source_object_id	=> P_NEW_SOURCE_VALUE,
                p_source_object_name => P_NEW_SOURCE_ID,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data	=> l_msg_data
                );
            end if; --end if(l_task_update_required=1)
            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF(P_REMOVE_ASSIGNMENT_FLAG = 'T') THEN
                FOR asg_rec in c_Assignment_details(P_TASK_ID_LIST(i))
                LOOP
                  jtf_task_assignments_pub.delete_task_assignment(
                  p_api_version => 1.0,
                  p_object_version_number => asg_rec.object_version_number,
                  p_task_assignment_id => asg_rec.task_assignment_id,
                  p_commit => FND_API.G_FALSE,
                  x_return_status => l_return_status,
                  x_msg_count => l_msg_count,
                  x_msg_data	=> l_msg_data);
                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                      l_update_status := 1;
                  END IF;
                  EXIT when l_update_status = 1;
                END LOOP;
                IF c_Assignment_details%ISOPEN
                THEN
                   close c_Assignment_details;
                END IF;
              END IF; --end IF(P_REMOVE_ASSIGNMENT_FLAG = 'T')
              IF (l_update_status = 0) THEN
                IF ( P_NOTE_TYPE is not null and P_NOTE_TYPE <> FND_API.G_MISS_CHAR)
                   OR ( P_NOTE_STATUS is not null and P_NOTE_STATUS <> FND_API.G_MISS_CHAR)
                   OR ( P_NOTE is not null and P_NOTE <> FND_API.G_MISS_CHAR)
                THEN
                  jtf_notes_pub.create_note(
                     p_api_version  =>1.0
                   , p_init_msg_list =>'F'
                   , p_commit =>'T'
                   , x_return_status =>l_note_return_status
                   , x_msg_count =>l_note_msg_count
                   , x_msg_data => l_note_msg_data
                   , p_source_object_id  => p_TASK_ID_LIST(i)
                   , p_source_object_code  => 'TASK'
                   , p_notes  => l_note
                   , p_note_status => p_note_status
                   , p_note_type  => p_note_type
                   , p_entered_by => FND_GLOBAL.USER_ID
                   , p_entered_date => sysdate
                   , x_jtf_note_id   => l_note_id
                   , p_last_update_date => sysdate
                   , p_last_updated_by => FND_GLOBAL.USER_ID
                   , p_creation_date => sysdate
                   , p_created_by => FND_GLOBAL.USER_ID
                   , p_last_update_login => FND_GLOBAL.LOGIN_ID
                   );
                END IF; --end note variable check
                IF fnd_api.to_boolean(p_commit) THEN
                  COMMIT WORK;
                END IF;
                l_SUCC_TASK_ID_LIST.extend;
                l_SUCC_TASK_ID_LIST(l_completed_index):=P_TASK_ID_LIST(i);
                l_completed_index:=l_completed_index+1;
              ELSE
                rollback to mass_task_update;
                l_failed_reason_list.extend;
                l_failed_task_id_list.extend;
                l_failed_reason_list(l_failed_index):=
                  fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST,
                              p_encoded =>'F' );
                l_failed_task_id_list(l_failed_index):=P_TASK_ID_LIST(i);
                l_failed_index:=l_failed_index+1;
              END IF; -- end IF (l_update_status = 0)
            ELSE
              rollback to mass_task_update;
              l_failed_reason_list.extend;
              l_failed_task_id_list.extend;
              l_failed_reason_list(l_failed_index):=fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST,
                              p_encoded =>'F');
              l_failed_task_id_list(l_failed_index):=P_TASK_ID_LIST(i);
              l_failed_index:=l_failed_index+1;
            END IF;  -- end IF (l_return_status = fnd_api.g_ret_sts_success)
          END LOOP;
      END IF; -- end IF( l_task_update_required=1 or P_REMOVE_ASSIGNMENT_FLAG = 'T')
      x_failed_reason_list:=l_failed_reason_list;
      x_failed_task_id_list:=l_failed_task_id_list;
      x_SUCC_TASK_ID_LIST:=l_SUCC_TASK_ID_LIST;
  END;
END;

/
