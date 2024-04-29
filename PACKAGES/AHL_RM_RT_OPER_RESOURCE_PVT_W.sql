--------------------------------------------------------
--  DDL for Package AHL_RM_RT_OPER_RESOURCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_RT_OPER_RESOURCE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWRORS.pls 120.1.12010000.2 2008/12/29 14:24:02 bachandr ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_rm_rt_oper_resource_pvt.rt_oper_resource_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t ahl_rm_rt_oper_resource_pvt.rt_oper_resource_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_rm_rt_oper_resource_pvt.alt_resource_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ahl_rm_rt_oper_resource_pvt.alt_resource_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_rt_oper_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_DATE_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_NUMBER_TABLE
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 in out nocopy JTF_NUMBER_TABLE
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a19 in out nocopy JTF_NUMBER_TABLE
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 in out nocopy JTF_NUMBER_TABLE
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a40 in out nocopy JTF_NUMBER_TABLE
    , p_association_type_code  VARCHAR2
    , p_object_id  NUMBER
  );
  procedure define_cost_parameter(p_api_version  NUMBER
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
    , p9_a2 in out nocopy  NUMBER
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  VARCHAR2
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  VARCHAR2
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  NUMBER
    , p9_a11 in out nocopy  VARCHAR2
  );
  procedure process_alternate_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rt_oper_resource_id  NUMBER
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_DATE_TABLE
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_DATE_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_NUMBER_TABLE
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_NUMBER_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_rm_rt_oper_resource_pvt_w;

/
