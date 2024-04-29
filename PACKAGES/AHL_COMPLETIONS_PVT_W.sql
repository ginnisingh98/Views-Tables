--------------------------------------------------------
--  DDL for Package AHL_COMPLETIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_COMPLETIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPRCS.pls 120.1 2005/07/04 10:46 rroy noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_completions_pvt.workorder_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t ahl_completions_pvt.workorder_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_completions_pvt.operation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_completions_pvt.operation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_completions_pvt.mr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p7(t ahl_completions_pvt.mr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy ahl_completions_pvt.counter_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t ahl_completions_pvt.counter_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy ahl_completions_pvt.route_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p10(t ahl_completions_pvt.route_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p18(t out nocopy ahl_completions_pvt.resource_req_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p18(t ahl_completions_pvt.resource_req_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    );

  procedure complete_mr_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  VARCHAR2
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  DATE
  );
  procedure signoff_mr_instance(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  DATE
    , p9_a6  DATE
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
  );
  procedure close_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER
    , p9_a1  NUMBER
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  DATE
    , p9_a6  DATE
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
  );
  procedure get_default_op_actual_dates(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a8 in out nocopy JTF_NUMBER_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_DATE_TABLE
    , p3_a11 in out nocopy JTF_DATE_TABLE
    , p3_a12 in out nocopy JTF_DATE_TABLE
    , p3_a13 in out nocopy JTF_DATE_TABLE
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_op_actual_dates(x_return_status out nocopy  VARCHAR2
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p1_a5 in out nocopy JTF_NUMBER_TABLE
    , p1_a6 in out nocopy JTF_NUMBER_TABLE
    , p1_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a8 in out nocopy JTF_NUMBER_TABLE
    , p1_a9 in out nocopy JTF_NUMBER_TABLE
    , p1_a10 in out nocopy JTF_DATE_TABLE
    , p1_a11 in out nocopy JTF_DATE_TABLE
    , p1_a12 in out nocopy JTF_DATE_TABLE
    , p1_a13 in out nocopy JTF_DATE_TABLE
    , p1_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a15 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_completions_pvt_w;

 

/
