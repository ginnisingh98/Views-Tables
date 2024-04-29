--------------------------------------------------------
--  DDL for Package Body JTA_CAL_APPOINTMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_CAL_APPOINTMENT_PVT_W" as
  /* $Header: jtavcawb.pls 120.2 2006/05/02 01:57 deeprao ship $ */
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

  procedure create_appointment(p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_timezone_id  NUMBER
    , p_private_flag  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_on  VARCHAR2
    , p_category_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);








    -- here's the delegated call to the old PL/SQL routine
    jta_cal_appointment_pvt.create_appointment(p_task_name,
      p_task_type_id,
      p_description,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      p_timezone_id,
      p_private_flag,
      p_alarm_start,
      p_alarm_on,
      p_category_id,
      x_return_status,
      x_task_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure create_appointment(p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_timezone_id  NUMBER
    , p_private_flag  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_on  VARCHAR2
    , p_category_id  NUMBER
    , p_free_busy_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_task_id out nocopy  NUMBER
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);









    -- here's the delegated call to the old PL/SQL routine
    jta_cal_appointment_pvt.create_appointment(p_task_name,
      p_task_type_id,
      p_description,
      p_task_priority_id,
      p_owner_type_code,
      p_owner_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      p_timezone_id,
      p_private_flag,
      p_alarm_start,
      p_alarm_on,
      p_category_id,
      p_free_busy_type,
      x_return_status,
      x_task_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure update_appointment(p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_timezone_id  NUMBER
    , p_private_flag  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_on  VARCHAR2
    , p_category_id  NUMBER
    , p_change_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);








    -- here's the delegated call to the old PL/SQL routine
    jta_cal_appointment_pvt.update_appointment(p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_priority_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      p_timezone_id,
      p_private_flag,
      p_alarm_start,
      p_alarm_on,
      p_category_id,
      p_change_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure update_appointment(p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_timezone_id  NUMBER
    , p_private_flag  VARCHAR2
    , p_alarm_start  NUMBER
    , p_alarm_on  VARCHAR2
    , p_category_id  NUMBER
    , p_free_busy_type  VARCHAR2
    , p_change_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_planned_start_date date;
    ddp_planned_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_planned_start_date := rosetta_g_miss_date_in_map(p_planned_start_date);

    ddp_planned_end_date := rosetta_g_miss_date_in_map(p_planned_end_date);









    -- here's the delegated call to the old PL/SQL routine
    jta_cal_appointment_pvt.update_appointment(p_object_version_number,
      p_task_id,
      p_task_name,
      p_task_type_id,
      p_description,
      p_task_priority_id,
      ddp_planned_start_date,
      ddp_planned_end_date,
      p_timezone_id,
      p_private_flag,
      p_alarm_start,
      p_alarm_on,
      p_category_id,
      p_free_busy_type,
      p_change_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

end jta_cal_appointment_pvt_w;

/
