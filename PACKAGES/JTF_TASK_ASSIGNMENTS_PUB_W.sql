--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENTS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfbtkas.pls 120.3 2006/04/26 04:18 knayyar ship $ */
  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_assignment_id out nocopy  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_object_capacity_id  NUMBER
    , p_free_busy_type  VARCHAR2
  );
  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_assignment_id out nocopy  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_object_capacity_id  NUMBER
  );
  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_assignment_id out nocopy  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  );
  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_task_assignment_id out nocopy  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
  );
  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_object_capacity_id  NUMBER
  );
  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  );
  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_name  VARCHAR2
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_schedule_flag  VARCHAR2
    , p_alarm_type_code  VARCHAR2
    , p_alarm_contact  VARCHAR2
    , p_sched_travel_distance  NUMBER
    , p_sched_travel_duration  NUMBER
    , p_sched_travel_duration_uom  VARCHAR2
    , p_actual_travel_distance  NUMBER
    , p_actual_travel_duration  NUMBER
    , p_actual_travel_duration_uom  VARCHAR2
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_resource_territory_id  NUMBER
    , p_assignment_status_id  NUMBER
    , p_shift_construct_id  NUMBER
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
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
  );
end jtf_task_assignments_pub_w;

 

/
