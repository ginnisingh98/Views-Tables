--------------------------------------------------------
--  DDL for Package JTF_TASK_WORKFLOW_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WORKFLOW_PKG_W" AUTHID CURRENT_USER as
  /* $Header: jtfrtkws.pls 120.2 2005/07/05 10:49:23 knayyar ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy jtf_task_workflow_pkg.task_details_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t jtf_task_workflow_pkg.task_details_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  function get_workflow_disp_name(p_item_type  VARCHAR2
    , p_process_name  VARCHAR2
    , p_raise_error  number
  ) return varchar2;
  procedure start_task_workflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_old_assignee_code  VARCHAR2
    , p_old_assignee_id  NUMBER
    , p_new_assignee_code  VARCHAR2
    , p_new_assignee_id  NUMBER
    , p_old_owner_code  VARCHAR2
    , p_old_owner_id  NUMBER
    , p_new_owner_code  VARCHAR2
    , p_new_owner_id  NUMBER
    , p12_a0 JTF_VARCHAR2_TABLE_100
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p_event  VARCHAR2
    , p_wf_display_name  VARCHAR2
    , p_wf_process  VARCHAR2
    , p_wf_item_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end jtf_task_workflow_pkg_w;

 

/
