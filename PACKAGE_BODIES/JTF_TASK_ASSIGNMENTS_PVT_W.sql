--------------------------------------------------------
--  DDL for Package Body JTF_TASK_ASSIGNMENTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_ASSIGNMENTS_PVT_W" as
  /* $Header: jtfvtawb.pls 120.2 2006/04/26 04:40 knayyar noship $ */
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

  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_add_option  VARCHAR2
    , p_free_busy_type  VARCHAR2
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);





































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.create_task_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_task_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_assignment_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow,
      p_add_option,
      p_free_busy_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























































  end;

  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_add_option  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_object_capacity_id  NUMBER
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);






































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.create_task_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_task_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_assignment_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow,
      p_add_option,
      p_free_busy_type,
      p_object_capacity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























































  end;

  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_add_option  VARCHAR2
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);




































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.create_task_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_task_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_assignment_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow,
      p_add_option);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















































  end;

  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.create_task_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_task_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_assignment_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















































  end;

  procedure create_task_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_task_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);

































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.create_task_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_task_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_task_assignment_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















































  end;

  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_free_busy_type  VARCHAR2
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);



































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.update_task_assignment(p_api_version,
      p_object_version_number,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow,
      p_free_busy_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















































  end;

  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_free_busy_type  VARCHAR2
    , p_object_capacity_id  NUMBER
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);




































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.update_task_assignment(p_api_version,
      p_object_version_number,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow,
      p_free_busy_type,
      p_object_capacity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















































  end;

  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);


































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.update_task_assignment(p_api_version,
      p_object_version_number,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id,
      p_enable_workflow,
      p_abort_workflow);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




















































  end;

  procedure update_task_assignment(p_api_version  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_assignment_id  NUMBER
    , p_resource_type_code  VARCHAR2
    , p_resource_id  NUMBER
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
    , p_assignee_role  VARCHAR2
    , p_show_on_calendar  VARCHAR2
    , p_category_id  NUMBER
  )

  as
    ddp_actual_start_date date;
    ddp_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    ddp_actual_start_date := rosetta_g_miss_date_in_map(p_actual_start_date);

    ddp_actual_end_date := rosetta_g_miss_date_in_map(p_actual_end_date);
































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_assignments_pvt.update_task_assignment(p_api_version,
      p_object_version_number,
      p_init_msg_list,
      p_commit,
      p_task_assignment_id,
      p_resource_type_code,
      p_resource_id,
      p_actual_effort,
      p_actual_effort_uom,
      p_schedule_flag,
      p_alarm_type_code,
      p_alarm_contact,
      p_sched_travel_distance,
      p_sched_travel_duration,
      p_sched_travel_duration_uom,
      p_actual_travel_distance,
      p_actual_travel_duration,
      p_actual_travel_duration_uom,
      ddp_actual_start_date,
      ddp_actual_end_date,
      p_palm_flag,
      p_wince_flag,
      p_laptop_flag,
      p_device1_flag,
      p_device2_flag,
      p_device3_flag,
      p_resource_territory_id,
      p_assignment_status_id,
      p_shift_construct_id,
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
      p_assignee_role,
      p_show_on_calendar,
      p_category_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















































  end;

end jtf_task_assignments_pvt_w;

/
