--------------------------------------------------------
--  DDL for Package AHL_PRD_WO_LOGIN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WO_LOGIN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLVLGWS.pls 120.0 2005/09/08 08:12 sracha noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_wo_login_pvt.wo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_prd_wo_login_pvt.wo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_wo_login_pvt.op_res_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_prd_wo_login_pvt.op_res_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_wo_login_info(p_function_name  VARCHAR2
    , p_employee_id  NUMBER
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_op_res_login_info(p_workorder_id  NUMBER
    , p_employee_id  NUMBER
    , p_function_name  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_prd_wo_login_pvt_w;

 

/
