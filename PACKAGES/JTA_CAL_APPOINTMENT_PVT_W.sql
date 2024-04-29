--------------------------------------------------------
--  DDL for Package JTA_CAL_APPOINTMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_CAL_APPOINTMENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtavcaws.pls 120.2 2006/04/28 02:17 deeprao ship $ */
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
  );
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
  );
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
  );
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
  );
end jta_cal_appointment_pvt_w;

 

/
