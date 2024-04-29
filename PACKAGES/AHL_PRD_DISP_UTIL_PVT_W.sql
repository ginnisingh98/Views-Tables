--------------------------------------------------------
--  DDL for Package AHL_PRD_DISP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISP_UTIL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWDIUS.pls 120.1 2008/01/29 14:17:24 sathapli ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_disp_util_pvt.disp_type_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_prd_disp_util_pvt.disp_type_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_prd_disp_util_pvt.disp_list_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ahl_prd_disp_util_pvt.disp_list_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_disposition_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row  NUMBER
    , p_rows_per_page  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  NUMBER
    , p9_a3  VARCHAR2
    , p9_a4  NUMBER
    , p9_a5  VARCHAR2
    , p9_a6  NUMBER
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , x_results_count out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_NUMBER_TABLE
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a24 out nocopy JTF_NUMBER_TABLE
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_part_change_disposition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorder_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_relationship_id  NUMBER
    , p_instance_id  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  VARCHAR2
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  DATE
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  DATE
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  NUMBER
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  VARCHAR
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  VARCHAR2
    , p11_a24 out nocopy  VARCHAR2
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  NUMBER
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR
    , p11_a31 out nocopy  VARCHAR
    , p11_a32 out nocopy  NUMBER
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR
    , p11_a35 out nocopy  VARCHAR
    , p11_a36 out nocopy  VARCHAR
    , p11_a37 out nocopy  VARCHAR
    , p11_a38 out nocopy  VARCHAR
    , p11_a39 out nocopy  VARCHAR
    , p11_a40 out nocopy  VARCHAR
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  VARCHAR2
    , p11_a47 out nocopy  VARCHAR2
    , p11_a48 out nocopy  VARCHAR2
    , p11_a49 out nocopy  VARCHAR2
    , p11_a50 out nocopy  VARCHAR2
    , p11_a51 out nocopy  VARCHAR2
    , p11_a52 out nocopy  VARCHAR2
    , p11_a53 out nocopy  VARCHAR2
    , p11_a54 out nocopy  VARCHAR2
    , p11_a55 out nocopy  VARCHAR2
    , p11_a56 out nocopy  VARCHAR2
    , p11_a57 out nocopy  VARCHAR2
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_available_disp_types(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_disposition_id  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_prd_disp_util_pvt_w;

/
