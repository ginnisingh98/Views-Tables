--------------------------------------------------------
--  DDL for Package JTF_TASKS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASKS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfbtkts.pls 120.7 2006/04/26 04:33 knayyar ship $ */
  procedure rosetta_table_copy_in_p6(t out nocopy jtf_tasks_pub.task_assign_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t jtf_tasks_pub.task_assign_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy jtf_tasks_pub.task_depends_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t jtf_tasks_pub.task_depends_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p12(t out nocopy jtf_tasks_pub.task_rsrc_req_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t jtf_tasks_pub.task_rsrc_req_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p15(t out nocopy jtf_tasks_pub.task_refer_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p15(t jtf_tasks_pub.task_refer_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p20(t out nocopy jtf_tasks_pub.task_dates_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p20(t jtf_tasks_pub.task_dates_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p23(t out nocopy jtf_tasks_pub.task_notes_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_32767
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p23(t jtf_tasks_pub.task_notes_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p26(t out nocopy jtf_tasks_pub.task_contacts_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p26(t jtf_tasks_pub.task_contacts_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p31(t out nocopy jtf_tasks_pub.task_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_4000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_4000
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_4000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_400
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_DATE_TABLE
    , a73 JTF_VARCHAR2_TABLE_4000
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_DATE_TABLE
    , a76 JTF_DATE_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p31(t jtf_tasks_pub.task_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_400
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_DATE_TABLE
    , a76 out nocopy JTF_DATE_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p34(t out nocopy jtf_tasks_pub.sort_data, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p34(t jtf_tasks_pub.sort_data, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p53(t out nocopy jtf_tasks_pub.task_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p53(t jtf_tasks_pub.task_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_number  VARCHAR2
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
    , p73_a0 JTF_VARCHAR2_TABLE_100
    , p73_a1 JTF_NUMBER_TABLE
    , p73_a2 JTF_DATE_TABLE
    , p73_a3 JTF_DATE_TABLE
    , p73_a4 JTF_NUMBER_TABLE
    , p73_a5 JTF_VARCHAR2_TABLE_100
    , p73_a6 JTF_NUMBER_TABLE
    , p73_a7 JTF_NUMBER_TABLE
    , p73_a8 JTF_VARCHAR2_TABLE_100
    , p73_a9 JTF_NUMBER_TABLE
    , p73_a10 JTF_NUMBER_TABLE
    , p73_a11 JTF_VARCHAR2_TABLE_100
    , p73_a12 JTF_VARCHAR2_TABLE_100
    , p73_a13 JTF_VARCHAR2_TABLE_100
    , p73_a14 JTF_VARCHAR2_TABLE_200
    , p73_a15 JTF_VARCHAR2_TABLE_100
    , p73_a16 JTF_VARCHAR2_TABLE_100
    , p73_a17 JTF_VARCHAR2_TABLE_100
    , p73_a18 JTF_VARCHAR2_TABLE_100
    , p73_a19 JTF_VARCHAR2_TABLE_100
    , p73_a20 JTF_VARCHAR2_TABLE_100
    , p73_a21 JTF_NUMBER_TABLE
    , p73_a22 JTF_NUMBER_TABLE
    , p73_a23 JTF_NUMBER_TABLE
    , p73_a24 JTF_VARCHAR2_TABLE_100
    , p73_a25 JTF_NUMBER_TABLE
    , p74_a0 JTF_NUMBER_TABLE
    , p74_a1 JTF_NUMBER_TABLE
    , p74_a2 JTF_VARCHAR2_TABLE_100
    , p74_a3 JTF_NUMBER_TABLE
    , p74_a4 JTF_VARCHAR2_TABLE_100
    , p74_a5 JTF_VARCHAR2_TABLE_100
    , p75_a0 JTF_VARCHAR2_TABLE_100
    , p75_a1 JTF_NUMBER_TABLE
    , p75_a2 JTF_VARCHAR2_TABLE_100
    , p76_a0 JTF_VARCHAR2_TABLE_100
    , p76_a1 JTF_VARCHAR2_TABLE_100
    , p76_a2 JTF_VARCHAR2_TABLE_100
    , p76_a3 JTF_NUMBER_TABLE
    , p76_a4 JTF_VARCHAR2_TABLE_2000
    , p76_a5 JTF_VARCHAR2_TABLE_100
    , p76_a6 JTF_VARCHAR2_TABLE_2000
    , p77_a0 JTF_NUMBER_TABLE
    , p77_a1 JTF_VARCHAR2_TABLE_100
    , p77_a2 JTF_VARCHAR2_TABLE_100
    , p77_a3 JTF_DATE_TABLE
    , p78_a0 JTF_NUMBER_TABLE
    , p78_a1 JTF_NUMBER_TABLE
    , p78_a2 JTF_VARCHAR2_TABLE_4000
    , p78_a3 JTF_VARCHAR2_TABLE_32767
    , p78_a4 JTF_VARCHAR2_TABLE_100
    , p78_a5 JTF_NUMBER_TABLE
    , p78_a6 JTF_DATE_TABLE
    , p78_a7 JTF_VARCHAR2_TABLE_100
    , p78_a8 JTF_NUMBER_TABLE
    , p78_a9 JTF_VARCHAR2_TABLE_200
    , p78_a10 JTF_VARCHAR2_TABLE_200
    , p78_a11 JTF_VARCHAR2_TABLE_200
    , p78_a12 JTF_VARCHAR2_TABLE_200
    , p78_a13 JTF_VARCHAR2_TABLE_200
    , p78_a14 JTF_VARCHAR2_TABLE_200
    , p78_a15 JTF_VARCHAR2_TABLE_200
    , p78_a16 JTF_VARCHAR2_TABLE_200
    , p78_a17 JTF_VARCHAR2_TABLE_200
    , p78_a18 JTF_VARCHAR2_TABLE_200
    , p78_a19 JTF_VARCHAR2_TABLE_200
    , p78_a20 JTF_VARCHAR2_TABLE_200
    , p78_a21 JTF_VARCHAR2_TABLE_200
    , p78_a22 JTF_VARCHAR2_TABLE_200
    , p78_a23 JTF_VARCHAR2_TABLE_200
    , p78_a24 JTF_VARCHAR2_TABLE_100
    , p79_a0  NUMBER
    , p79_a1  NUMBER
    , p79_a2  NUMBER
    , p79_a3  NUMBER
    , p79_a4  VARCHAR2
    , p79_a5  NUMBER
    , p79_a6  NUMBER
    , p79_a7  DATE
    , p79_a8  DATE
    , p80_a0 JTF_NUMBER_TABLE
    , p80_a1 JTF_VARCHAR2_TABLE_100
    , p80_a2 JTF_VARCHAR2_TABLE_100
    , p80_a3 JTF_VARCHAR2_TABLE_100
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
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  );
  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_number  VARCHAR2
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
    , p_task_split_flag  VARCHAR2
    , p_reference_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  );
  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_number  VARCHAR2
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
  );
  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_number  VARCHAR2
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
    , p73_a0 JTF_VARCHAR2_TABLE_100
    , p73_a1 JTF_NUMBER_TABLE
    , p73_a2 JTF_DATE_TABLE
    , p73_a3 JTF_DATE_TABLE
    , p73_a4 JTF_NUMBER_TABLE
    , p73_a5 JTF_VARCHAR2_TABLE_100
    , p73_a6 JTF_NUMBER_TABLE
    , p73_a7 JTF_NUMBER_TABLE
    , p73_a8 JTF_VARCHAR2_TABLE_100
    , p73_a9 JTF_NUMBER_TABLE
    , p73_a10 JTF_NUMBER_TABLE
    , p73_a11 JTF_VARCHAR2_TABLE_100
    , p73_a12 JTF_VARCHAR2_TABLE_100
    , p73_a13 JTF_VARCHAR2_TABLE_100
    , p73_a14 JTF_VARCHAR2_TABLE_200
    , p73_a15 JTF_VARCHAR2_TABLE_100
    , p73_a16 JTF_VARCHAR2_TABLE_100
    , p73_a17 JTF_VARCHAR2_TABLE_100
    , p73_a18 JTF_VARCHAR2_TABLE_100
    , p73_a19 JTF_VARCHAR2_TABLE_100
    , p73_a20 JTF_VARCHAR2_TABLE_100
    , p73_a21 JTF_NUMBER_TABLE
    , p73_a22 JTF_NUMBER_TABLE
    , p73_a23 JTF_NUMBER_TABLE
    , p73_a24 JTF_VARCHAR2_TABLE_100
    , p73_a25 JTF_NUMBER_TABLE
    , p74_a0 JTF_NUMBER_TABLE
    , p74_a1 JTF_NUMBER_TABLE
    , p74_a2 JTF_VARCHAR2_TABLE_100
    , p74_a3 JTF_NUMBER_TABLE
    , p74_a4 JTF_VARCHAR2_TABLE_100
    , p74_a5 JTF_VARCHAR2_TABLE_100
    , p75_a0 JTF_VARCHAR2_TABLE_100
    , p75_a1 JTF_NUMBER_TABLE
    , p75_a2 JTF_VARCHAR2_TABLE_100
    , p76_a0 JTF_VARCHAR2_TABLE_100
    , p76_a1 JTF_VARCHAR2_TABLE_100
    , p76_a2 JTF_VARCHAR2_TABLE_100
    , p76_a3 JTF_NUMBER_TABLE
    , p76_a4 JTF_VARCHAR2_TABLE_2000
    , p76_a5 JTF_VARCHAR2_TABLE_100
    , p76_a6 JTF_VARCHAR2_TABLE_2000
    , p77_a0 JTF_NUMBER_TABLE
    , p77_a1 JTF_VARCHAR2_TABLE_100
    , p77_a2 JTF_VARCHAR2_TABLE_100
    , p77_a3 JTF_DATE_TABLE
    , p78_a0 JTF_NUMBER_TABLE
    , p78_a1 JTF_NUMBER_TABLE
    , p78_a2 JTF_VARCHAR2_TABLE_4000
    , p78_a3 JTF_VARCHAR2_TABLE_32767
    , p78_a4 JTF_VARCHAR2_TABLE_100
    , p78_a5 JTF_NUMBER_TABLE
    , p78_a6 JTF_DATE_TABLE
    , p78_a7 JTF_VARCHAR2_TABLE_100
    , p78_a8 JTF_NUMBER_TABLE
    , p78_a9 JTF_VARCHAR2_TABLE_200
    , p78_a10 JTF_VARCHAR2_TABLE_200
    , p78_a11 JTF_VARCHAR2_TABLE_200
    , p78_a12 JTF_VARCHAR2_TABLE_200
    , p78_a13 JTF_VARCHAR2_TABLE_200
    , p78_a14 JTF_VARCHAR2_TABLE_200
    , p78_a15 JTF_VARCHAR2_TABLE_200
    , p78_a16 JTF_VARCHAR2_TABLE_200
    , p78_a17 JTF_VARCHAR2_TABLE_200
    , p78_a18 JTF_VARCHAR2_TABLE_200
    , p78_a19 JTF_VARCHAR2_TABLE_200
    , p78_a20 JTF_VARCHAR2_TABLE_200
    , p78_a21 JTF_VARCHAR2_TABLE_200
    , p78_a22 JTF_VARCHAR2_TABLE_200
    , p78_a23 JTF_VARCHAR2_TABLE_200
    , p78_a24 JTF_VARCHAR2_TABLE_100
    , p79_a0  NUMBER
    , p79_a1  NUMBER
    , p79_a2  NUMBER
    , p79_a3  NUMBER
    , p79_a4  VARCHAR2
    , p79_a5  NUMBER
    , p79_a6  NUMBER
    , p79_a7  DATE
    , p79_a8  DATE
    , p80_a0 JTF_NUMBER_TABLE
    , p80_a1 JTF_VARCHAR2_TABLE_100
    , p80_a2 JTF_VARCHAR2_TABLE_100
    , p80_a3 JTF_VARCHAR2_TABLE_100
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
  );
  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
    , p_location_id  NUMBER
  );
  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , p_task_split_flag  VARCHAR2
    , p_child_position  VARCHAR2
    , p_child_sequence_num  NUMBER
  );
  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
    , p_enable_workflow  VARCHAR2
    , p_abort_workflow  VARCHAR2
  );
  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_task_name  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_description  VARCHAR2
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_assigned_by_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_customer_number  VARCHAR2
    , p_customer_id  NUMBER
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_address_id  NUMBER
    , p_address_number  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_timezone_id  NUMBER
    , p_timezone_name  VARCHAR2
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
    , p_parent_task_id  NUMBER
    , p_parent_task_number  VARCHAR2
  );
  procedure export_query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p49_a0 JTF_VARCHAR2_TABLE_100
    , p49_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p54_a0 out nocopy JTF_NUMBER_TABLE
    , p54_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a4 out nocopy JTF_NUMBER_TABLE
    , p54_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a6 out nocopy JTF_NUMBER_TABLE
    , p54_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a8 out nocopy JTF_NUMBER_TABLE
    , p54_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a11 out nocopy JTF_NUMBER_TABLE
    , p54_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a13 out nocopy JTF_NUMBER_TABLE
    , p54_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a15 out nocopy JTF_NUMBER_TABLE
    , p54_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p54_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a19 out nocopy JTF_NUMBER_TABLE
    , p54_a20 out nocopy JTF_NUMBER_TABLE
    , p54_a21 out nocopy JTF_DATE_TABLE
    , p54_a22 out nocopy JTF_DATE_TABLE
    , p54_a23 out nocopy JTF_DATE_TABLE
    , p54_a24 out nocopy JTF_DATE_TABLE
    , p54_a25 out nocopy JTF_DATE_TABLE
    , p54_a26 out nocopy JTF_DATE_TABLE
    , p54_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a28 out nocopy JTF_NUMBER_TABLE
    , p54_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a30 out nocopy JTF_NUMBER_TABLE
    , p54_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a32 out nocopy JTF_NUMBER_TABLE
    , p54_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a34 out nocopy JTF_NUMBER_TABLE
    , p54_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a36 out nocopy JTF_NUMBER_TABLE
    , p54_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a43 out nocopy JTF_NUMBER_TABLE
    , p54_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a45 out nocopy JTF_NUMBER_TABLE
    , p54_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a47 out nocopy JTF_NUMBER_TABLE
    , p54_a48 out nocopy JTF_NUMBER_TABLE
    , p54_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a51 out nocopy JTF_NUMBER_TABLE
    , p54_a52 out nocopy JTF_NUMBER_TABLE
    , p54_a53 out nocopy JTF_NUMBER_TABLE
    , p54_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a71 out nocopy JTF_NUMBER_TABLE
    , p54_a72 out nocopy JTF_DATE_TABLE
    , p54_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a74 out nocopy JTF_NUMBER_TABLE
    , p54_a75 out nocopy JTF_DATE_TABLE
    , p54_a76 out nocopy JTF_DATE_TABLE
    , p54_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a80 out nocopy JTF_NUMBER_TABLE
    , p54_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , p_location_id  NUMBER
  );
  procedure export_query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p49_a0 JTF_VARCHAR2_TABLE_100
    , p49_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p54_a0 out nocopy JTF_NUMBER_TABLE
    , p54_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a4 out nocopy JTF_NUMBER_TABLE
    , p54_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a6 out nocopy JTF_NUMBER_TABLE
    , p54_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a8 out nocopy JTF_NUMBER_TABLE
    , p54_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a11 out nocopy JTF_NUMBER_TABLE
    , p54_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a13 out nocopy JTF_NUMBER_TABLE
    , p54_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a15 out nocopy JTF_NUMBER_TABLE
    , p54_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p54_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a19 out nocopy JTF_NUMBER_TABLE
    , p54_a20 out nocopy JTF_NUMBER_TABLE
    , p54_a21 out nocopy JTF_DATE_TABLE
    , p54_a22 out nocopy JTF_DATE_TABLE
    , p54_a23 out nocopy JTF_DATE_TABLE
    , p54_a24 out nocopy JTF_DATE_TABLE
    , p54_a25 out nocopy JTF_DATE_TABLE
    , p54_a26 out nocopy JTF_DATE_TABLE
    , p54_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a28 out nocopy JTF_NUMBER_TABLE
    , p54_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a30 out nocopy JTF_NUMBER_TABLE
    , p54_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a32 out nocopy JTF_NUMBER_TABLE
    , p54_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a34 out nocopy JTF_NUMBER_TABLE
    , p54_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a36 out nocopy JTF_NUMBER_TABLE
    , p54_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a43 out nocopy JTF_NUMBER_TABLE
    , p54_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a45 out nocopy JTF_NUMBER_TABLE
    , p54_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a47 out nocopy JTF_NUMBER_TABLE
    , p54_a48 out nocopy JTF_NUMBER_TABLE
    , p54_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a51 out nocopy JTF_NUMBER_TABLE
    , p54_a52 out nocopy JTF_NUMBER_TABLE
    , p54_a53 out nocopy JTF_NUMBER_TABLE
    , p54_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p54_a71 out nocopy JTF_NUMBER_TABLE
    , p54_a72 out nocopy JTF_DATE_TABLE
    , p54_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p54_a74 out nocopy JTF_NUMBER_TABLE
    , p54_a75 out nocopy JTF_DATE_TABLE
    , p54_a76 out nocopy JTF_DATE_TABLE
    , p54_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p54_a80 out nocopy JTF_NUMBER_TABLE
    , p54_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  );
  procedure query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p48_a0 JTF_VARCHAR2_TABLE_100
    , p48_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p53_a0 out nocopy JTF_NUMBER_TABLE
    , p53_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a4 out nocopy JTF_NUMBER_TABLE
    , p53_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a6 out nocopy JTF_NUMBER_TABLE
    , p53_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a8 out nocopy JTF_NUMBER_TABLE
    , p53_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a11 out nocopy JTF_NUMBER_TABLE
    , p53_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a13 out nocopy JTF_NUMBER_TABLE
    , p53_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a15 out nocopy JTF_NUMBER_TABLE
    , p53_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p53_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a19 out nocopy JTF_NUMBER_TABLE
    , p53_a20 out nocopy JTF_NUMBER_TABLE
    , p53_a21 out nocopy JTF_DATE_TABLE
    , p53_a22 out nocopy JTF_DATE_TABLE
    , p53_a23 out nocopy JTF_DATE_TABLE
    , p53_a24 out nocopy JTF_DATE_TABLE
    , p53_a25 out nocopy JTF_DATE_TABLE
    , p53_a26 out nocopy JTF_DATE_TABLE
    , p53_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a28 out nocopy JTF_NUMBER_TABLE
    , p53_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a30 out nocopy JTF_NUMBER_TABLE
    , p53_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a32 out nocopy JTF_NUMBER_TABLE
    , p53_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a34 out nocopy JTF_NUMBER_TABLE
    , p53_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a36 out nocopy JTF_NUMBER_TABLE
    , p53_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a43 out nocopy JTF_NUMBER_TABLE
    , p53_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a45 out nocopy JTF_NUMBER_TABLE
    , p53_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a47 out nocopy JTF_NUMBER_TABLE
    , p53_a48 out nocopy JTF_NUMBER_TABLE
    , p53_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a51 out nocopy JTF_NUMBER_TABLE
    , p53_a52 out nocopy JTF_NUMBER_TABLE
    , p53_a53 out nocopy JTF_NUMBER_TABLE
    , p53_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a71 out nocopy JTF_NUMBER_TABLE
    , p53_a72 out nocopy JTF_DATE_TABLE
    , p53_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a74 out nocopy JTF_NUMBER_TABLE
    , p53_a75 out nocopy JTF_DATE_TABLE
    , p53_a76 out nocopy JTF_DATE_TABLE
    , p53_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a80 out nocopy JTF_NUMBER_TABLE
    , p53_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
    , p_location_id  NUMBER
  );
  procedure query_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_number  VARCHAR2
    , p_task_id  NUMBER
    , p_task_name  VARCHAR2
    , p_description  VARCHAR2
    , p_task_type_name  VARCHAR2
    , p_task_type_id  NUMBER
    , p_task_status_name  VARCHAR2
    , p_task_status_id  NUMBER
    , p_task_priority_name  VARCHAR2
    , p_task_priority_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_assigned_name  VARCHAR2
    , p_assigned_by_id  NUMBER
    , p_address_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_customer_id  NUMBER
    , p_customer_name  VARCHAR2
    , p_customer_number  VARCHAR2
    , p_cust_account_number  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_object_type_code  VARCHAR2
    , p_object_name  VARCHAR2
    , p_source_object_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_reason_code  VARCHAR2
    , p_private_flag  VARCHAR2
    , p_restrict_closure_flag  VARCHAR2
    , p_multi_booked_flag  VARCHAR2
    , p_milestone_flag  VARCHAR2
    , p_holiday_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_notification_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_alarm_on  VARCHAR2
    , p_alarm_count  NUMBER
    , p_alarm_fired_count  NUMBER
    , p_ref_object_id  NUMBER
    , p_ref_object_type_code  VARCHAR2
    , p48_a0 JTF_VARCHAR2_TABLE_100
    , p48_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p53_a0 out nocopy JTF_NUMBER_TABLE
    , p53_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a4 out nocopy JTF_NUMBER_TABLE
    , p53_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a6 out nocopy JTF_NUMBER_TABLE
    , p53_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a8 out nocopy JTF_NUMBER_TABLE
    , p53_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a11 out nocopy JTF_NUMBER_TABLE
    , p53_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a13 out nocopy JTF_NUMBER_TABLE
    , p53_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a15 out nocopy JTF_NUMBER_TABLE
    , p53_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p53_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a19 out nocopy JTF_NUMBER_TABLE
    , p53_a20 out nocopy JTF_NUMBER_TABLE
    , p53_a21 out nocopy JTF_DATE_TABLE
    , p53_a22 out nocopy JTF_DATE_TABLE
    , p53_a23 out nocopy JTF_DATE_TABLE
    , p53_a24 out nocopy JTF_DATE_TABLE
    , p53_a25 out nocopy JTF_DATE_TABLE
    , p53_a26 out nocopy JTF_DATE_TABLE
    , p53_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a28 out nocopy JTF_NUMBER_TABLE
    , p53_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a30 out nocopy JTF_NUMBER_TABLE
    , p53_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a32 out nocopy JTF_NUMBER_TABLE
    , p53_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a34 out nocopy JTF_NUMBER_TABLE
    , p53_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a36 out nocopy JTF_NUMBER_TABLE
    , p53_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a43 out nocopy JTF_NUMBER_TABLE
    , p53_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a45 out nocopy JTF_NUMBER_TABLE
    , p53_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a47 out nocopy JTF_NUMBER_TABLE
    , p53_a48 out nocopy JTF_NUMBER_TABLE
    , p53_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a51 out nocopy JTF_NUMBER_TABLE
    , p53_a52 out nocopy JTF_NUMBER_TABLE
    , p53_a53 out nocopy JTF_NUMBER_TABLE
    , p53_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p53_a71 out nocopy JTF_NUMBER_TABLE
    , p53_a72 out nocopy JTF_DATE_TABLE
    , p53_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p53_a74 out nocopy JTF_NUMBER_TABLE
    , p53_a75 out nocopy JTF_DATE_TABLE
    , p53_a76 out nocopy JTF_DATE_TABLE
    , p53_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p53_a80 out nocopy JTF_NUMBER_TABLE
    , p53_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  );
  procedure query_next_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_task_id  NUMBER
    , p_query_type  VARCHAR2
    , p_date_type  VARCHAR2
    , p_date_start_or_end  VARCHAR2
    , p_owner_id  NUMBER
    , p_owner_type_code  VARCHAR2
    , p_assigned_by  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p_start_pointer  NUMBER
    , p_rec_wanted  NUMBER
    , p_show_all  VARCHAR2
    , p_query_or_next_code  VARCHAR2
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a4 out nocopy JTF_NUMBER_TABLE
    , p15_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a8 out nocopy JTF_NUMBER_TABLE
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a11 out nocopy JTF_NUMBER_TABLE
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a13 out nocopy JTF_NUMBER_TABLE
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_400
    , p15_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_NUMBER_TABLE
    , p15_a20 out nocopy JTF_NUMBER_TABLE
    , p15_a21 out nocopy JTF_DATE_TABLE
    , p15_a22 out nocopy JTF_DATE_TABLE
    , p15_a23 out nocopy JTF_DATE_TABLE
    , p15_a24 out nocopy JTF_DATE_TABLE
    , p15_a25 out nocopy JTF_DATE_TABLE
    , p15_a26 out nocopy JTF_DATE_TABLE
    , p15_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a28 out nocopy JTF_NUMBER_TABLE
    , p15_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a30 out nocopy JTF_NUMBER_TABLE
    , p15_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a32 out nocopy JTF_NUMBER_TABLE
    , p15_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a34 out nocopy JTF_NUMBER_TABLE
    , p15_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a36 out nocopy JTF_NUMBER_TABLE
    , p15_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a43 out nocopy JTF_NUMBER_TABLE
    , p15_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a45 out nocopy JTF_NUMBER_TABLE
    , p15_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a47 out nocopy JTF_NUMBER_TABLE
    , p15_a48 out nocopy JTF_NUMBER_TABLE
    , p15_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a51 out nocopy JTF_NUMBER_TABLE
    , p15_a52 out nocopy JTF_NUMBER_TABLE
    , p15_a53 out nocopy JTF_NUMBER_TABLE
    , p15_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a71 out nocopy JTF_NUMBER_TABLE
    , p15_a72 out nocopy JTF_DATE_TABLE
    , p15_a73 out nocopy JTF_VARCHAR2_TABLE_4000
    , p15_a74 out nocopy JTF_NUMBER_TABLE
    , p15_a75 out nocopy JTF_DATE_TABLE
    , p15_a76 out nocopy JTF_DATE_TABLE
    , p15_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a80 out nocopy JTF_NUMBER_TABLE
    , p15_a81 out nocopy JTF_NUMBER_TABLE
    , x_total_retrieved out nocopy  NUMBER
    , x_total_returned out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  );
  procedure export_file(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_file_name  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_VARCHAR2_TABLE_4000
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_VARCHAR2_TABLE_4000
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_4000
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_400
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_DATE_TABLE
    , p4_a22 JTF_DATE_TABLE
    , p4_a23 JTF_DATE_TABLE
    , p4_a24 JTF_DATE_TABLE
    , p4_a25 JTF_DATE_TABLE
    , p4_a26 JTF_DATE_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_NUMBER_TABLE
    , p4_a33 JTF_VARCHAR2_TABLE_100
    , p4_a34 JTF_NUMBER_TABLE
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_NUMBER_TABLE
    , p4_a37 JTF_VARCHAR2_TABLE_100
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_VARCHAR2_TABLE_100
    , p4_a45 JTF_NUMBER_TABLE
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_NUMBER_TABLE
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_VARCHAR2_TABLE_100
    , p4_a50 JTF_VARCHAR2_TABLE_100
    , p4_a51 JTF_NUMBER_TABLE
    , p4_a52 JTF_NUMBER_TABLE
    , p4_a53 JTF_NUMBER_TABLE
    , p4_a54 JTF_VARCHAR2_TABLE_100
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_NUMBER_TABLE
    , p4_a72 JTF_DATE_TABLE
    , p4_a73 JTF_VARCHAR2_TABLE_4000
    , p4_a74 JTF_NUMBER_TABLE
    , p4_a75 JTF_DATE_TABLE
    , p4_a76 JTF_DATE_TABLE
    , p4_a77 JTF_VARCHAR2_TABLE_100
    , p4_a78 JTF_VARCHAR2_TABLE_100
    , p4_a79 JTF_VARCHAR2_TABLE_100
    , p4_a80 JTF_NUMBER_TABLE
    , p4_a81 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  );
  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_template_group_id  NUMBER
    , p_task_template_group_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p_assigned_by_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_timezone_id  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_reason_code  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
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
    , p_location_id  NUMBER
  );
  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_template_group_id  NUMBER
    , p_task_template_group_name  VARCHAR2
    , p_owner_type_code  VARCHAR2
    , p_owner_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p_assigned_by_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_customer_id  NUMBER
    , p_address_id  NUMBER
    , p_actual_start_date  date
    , p_actual_end_date  date
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_scheduled_start_date  date
    , p_scheduled_end_date  date
    , p_palm_flag  VARCHAR2
    , p_wince_flag  VARCHAR2
    , p_laptop_flag  VARCHAR2
    , p_device1_flag  VARCHAR2
    , p_device2_flag  VARCHAR2
    , p_device3_flag  VARCHAR2
    , p_parent_task_id  NUMBER
    , p_percentage_complete  NUMBER
    , p_timezone_id  NUMBER
    , p_actual_effort  NUMBER
    , p_actual_effort_uom  VARCHAR2
    , p_reason_code  VARCHAR2
    , p_bound_mode_code  VARCHAR2
    , p_soft_bound_flag  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_owner_territory_id  NUMBER
    , p_costs  NUMBER
    , p_currency_code  VARCHAR2
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
  );
end jtf_tasks_pub_w;

 

/
