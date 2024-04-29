--------------------------------------------------------
--  DDL for Package JTA_CAL_ATTENDEES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_CAL_ATTENDEES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtacatws.pls 115.1 2002/12/07 01:31:19 rdespoto ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jta_cal_attendees_pvt.resource_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jta_cal_attendees_pvt.resource_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy jta_cal_attendees_pvt.task_assign_tbl, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jta_cal_attendees_pvt.task_assign_tbl, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_cal_assignment(p_task_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p_add_option  VARCHAR2
    , p_invitor_res_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_cal_assignment(p_object_version_number  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p_delete_option  VARCHAR2
    , p_no_of_attendies  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
end jta_cal_attendees_pvt_w;

 

/
