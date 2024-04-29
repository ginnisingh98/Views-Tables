--------------------------------------------------------
--  DDL for Package AHL_PRD_OPERATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_OPERATIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPROS.pls 120.1 2006/02/08 06:04 bachandr noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_operations_pvt.prd_operation_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_prd_operations_pvt.prd_operation_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_operations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , p_wip_mass_load_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_NUMBER_TABLE
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_NUMBER_TABLE
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 in out nocopy JTF_NUMBER_TABLE
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 in out nocopy JTF_NUMBER_TABLE
    , p10_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a24 in out nocopy JTF_DATE_TABLE
    , p10_a25 in out nocopy JTF_NUMBER_TABLE
    , p10_a26 in out nocopy JTF_NUMBER_TABLE
    , p10_a27 in out nocopy JTF_DATE_TABLE
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p10_a30 in out nocopy JTF_DATE_TABLE
    , p10_a31 in out nocopy JTF_NUMBER_TABLE
    , p10_a32 in out nocopy JTF_NUMBER_TABLE
    , p10_a33 in out nocopy JTF_DATE_TABLE
    , p10_a34 in out nocopy JTF_NUMBER_TABLE
    , p10_a35 in out nocopy JTF_NUMBER_TABLE
    , p10_a36 in out nocopy JTF_NUMBER_TABLE
    , p10_a37 in out nocopy JTF_NUMBER_TABLE
    , p10_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 in out nocopy JTF_NUMBER_TABLE
    , p10_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a56 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_prd_operations_pvt_w;

 

/
