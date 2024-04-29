--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_PVT_W" as
  /* $Header: jtfrtktb.pls 120.4 2006/04/26 04:38 knayyar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);






































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


























































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_entity  VARCHAR2
    , p_free_busy_type  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);








































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow,
      p_entity,
      p_free_busy_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




























































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_entity  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_task_confirmation_status  VARCHAR2
    , p_task_confirmation_counter  NUMBER
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);















































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow,
      p_entity,
      p_free_busy_type,
      p_task_confirmation_status,
      p_task_confirmation_counter,
      p_task_split_flag,
      p_reference_flag,
      p_child_position,
      p_child_sequence_num,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



































































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_entity  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_task_confirmation_status  VARCHAR2
    , p_task_confirmation_counter  NUMBER
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);














































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id,
      p_enable_workflow,
      p_abort_workflow,
      p_entity,
      p_free_busy_type,
      p_task_confirmation_status,
      p_task_confirmation_counter,
      p_task_split_flag,
      p_reference_flag,
      p_child_position,
      p_child_sequence_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


































































































  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_template_id  NUMBER
    , p_template_group_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);




































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_id,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_template_id,
      p_template_group_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_change_mode  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);





































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_enable_workflow,
      p_abort_workflow,
      p_change_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


























































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_change_mode  VARCHAR2
    , p_free_busy_type  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);






































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_enable_workflow,
      p_abort_workflow,
      p_change_mode,
      p_free_busy_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



























































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_change_mode  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_task_confirmation_status  VARCHAR2
    , p_task_confirmation_counter  NUMBER
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);












































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_enable_workflow,
      p_abort_workflow,
      p_change_mode,
      p_free_busy_type,
      p_task_confirmation_status,
      p_task_confirmation_counter,
      p_task_split_flag,
      p_child_position,
      p_child_sequence_num,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_change_mode  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_task_confirmation_status  VARCHAR2
    , p_task_confirmation_counter  NUMBER
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);











































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_enable_workflow,
      p_abort_workflow,
      p_change_mode,
      p_free_busy_type,
      p_task_confirmation_status,
      p_task_confirmation_counter,
      p_task_split_flag,
      p_child_position,
      p_child_sequence_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
































































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);




































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

























































































  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_id  NUMBER
    , p_customer_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , p_duration  NUMBER
    , p_duration_uom  VARCHAR2
    , p_planned_effort  NUMBER
    , p_planned_effort_uom  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_publish_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_billable_flag  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_notification_period  NUMBER
    , p_notification_period_uom  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_start  NUMBER
    , p_alarm_start_uom  VARCHAR2
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_alarm_interval  NUMBER
    , p_alarm_interval_uom  VARCHAR2
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
    , p_escalation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_date_selected  VARCHAR2
    , p_category_id  NUMBER
    , p_show_on_calendar  VARCHAR2
    , p_owner_status_id  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddp_scheduled_start_date date;
    ddp_scheduled_end_date date;
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);

    ddp_scheduled_start_date := rosetta_g_miss_date_in_map(p_scheduled_start_date);

    ddp_scheduled_end_date := rosetta_g_miss_date_in_map(p_scheduled_end_date);

    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);


































































    -- here's the delegated call to the old PL/SQL routine
    jtf_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_status_id,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      p_owner_territory_id,
      p_assigned_by_id,
      p_customer_id,
      p_cust_account_id,
      p_address_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      ddp_scheduled_start_date,
      ddp_scheduled_end_date,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_timezone_id,
      p_source_object_type_code,
      p_source_object_id,
      p_source_object_name,
      p_duration,
      p_duration_uom,
      p_planned_effort,
      p_planned_effort_uom,
      p_actual_effort,
      p_actual_effort_uom,
      p_percentage_complete,
      p_reason_code,
      p_private_flag,
      p_publish_flag,
      p_restrict_closure_flag,
      p_multi_booked_flag,
      p_milestone_flag,
      p_holiday_flag,
      p_billable_flag,
      p_bound_mode_code,
      p_soft_bound_flag,
      p_workflow_process_id,
      p_notification_flag,
      p_notification_period,
      p_notification_period_uom,
      p_parent_task_id,
      p_alarm_start,
      p_alarm_start_uom,
      p_alarm_on,
      p_alarm_count,
      p_alarm_fired_count,
      p_alarm_interval,
      p_alarm_interval_uom,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_costs,
      p_currency_code,
      p_escalation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      p_date_selected,
      p_category_id,
      p_show_on_calendar,
      p_owner_status_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























































































  end;

end jtf_tasks_pvt_w;

/
