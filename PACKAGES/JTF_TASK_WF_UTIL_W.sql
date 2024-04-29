--------------------------------------------------------
--  DDL for Package JTF_TASK_WF_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WF_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: jtfvtkws.pls 120.2 2006/04/26 04:42 knayyar ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy jtf_task_wf_util.nlist_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p4(t jtf_task_wf_util.nlist_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    );

  procedure do_notification(p_task_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure create_notification(p_event  VARCHAR2
    , p_task_id  NUMBER
    , p_old_owner_id  NUMBER
    , p_old_owner_code  VARCHAR2
    , p_old_assignee_id  NUMBER
    , p_old_assignee_code  VARCHAR2
    , p_new_assignee_id  NUMBER
    , p_new_assignee_code  VARCHAR2
    , p_old_type  NUMBER
    , p_old_priority  NUMBER
    , p_old_status  NUMBER
    , p_old_planned_start_date  date
    , p_old_planned_end_date  date
    , p_old_scheduled_start_date  date
    , p_old_scheduled_end_date  date
    , p_old_actual_start_date  date
    , p_old_actual_end_date  date
    , p_old_description  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end jtf_task_wf_util_w;

 

/
