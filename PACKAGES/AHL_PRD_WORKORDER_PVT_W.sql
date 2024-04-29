--------------------------------------------------------
--  DDL for Package AHL_PRD_WORKORDER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WORKORDER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPRJS.pls 120.3.12010000.2 2008/12/15 01:46:34 sracha ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_workorder_pvt.prd_workoper_tbl, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p1(t ahl_prd_workorder_pvt.prd_workoper_tbl, a0 out nocopy JTF_NUMBER_TABLE
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

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_workorder_pvt.prd_workorder_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_200
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_DATE_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_prd_workorder_pvt.prd_workorder_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_DATE_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_NUMBER_TABLE
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_VARCHAR2_TABLE_100
    , a100 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_prd_workorder_pvt.prd_workorder_rel_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ahl_prd_workorder_pvt.prd_workorder_rel_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p13(t out nocopy ahl_prd_workorder_pvt.turnover_notes_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t ahl_prd_workorder_pvt.turnover_notes_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_jobs(p_api_version  NUMBER
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
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 in out nocopy JTF_DATE_TABLE
    , p9_a16 in out nocopy JTF_NUMBER_TABLE
    , p9_a17 in out nocopy JTF_NUMBER_TABLE
    , p9_a18 in out nocopy JTF_DATE_TABLE
    , p9_a19 in out nocopy JTF_NUMBER_TABLE
    , p9_a20 in out nocopy JTF_NUMBER_TABLE
    , p9_a21 in out nocopy JTF_DATE_TABLE
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p9_a24 in out nocopy JTF_DATE_TABLE
    , p9_a25 in out nocopy JTF_NUMBER_TABLE
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p9_a28 in out nocopy JTF_NUMBER_TABLE
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 in out nocopy JTF_NUMBER_TABLE
    , p9_a37 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 in out nocopy JTF_NUMBER_TABLE
    , p9_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a40 in out nocopy JTF_NUMBER_TABLE
    , p9_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a42 in out nocopy JTF_NUMBER_TABLE
    , p9_a43 in out nocopy JTF_NUMBER_TABLE
    , p9_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a45 in out nocopy JTF_NUMBER_TABLE
    , p9_a46 in out nocopy JTF_NUMBER_TABLE
    , p9_a47 in out nocopy JTF_NUMBER_TABLE
    , p9_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a49 in out nocopy JTF_NUMBER_TABLE
    , p9_a50 in out nocopy JTF_NUMBER_TABLE
    , p9_a51 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a52 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a53 in out nocopy JTF_NUMBER_TABLE
    , p9_a54 in out nocopy JTF_NUMBER_TABLE
    , p9_a55 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a56 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a58 in out nocopy JTF_NUMBER_TABLE
    , p9_a59 in out nocopy JTF_NUMBER_TABLE
    , p9_a60 in out nocopy JTF_NUMBER_TABLE
    , p9_a61 in out nocopy JTF_NUMBER_TABLE
    , p9_a62 in out nocopy JTF_NUMBER_TABLE
    , p9_a63 in out nocopy JTF_NUMBER_TABLE
    , p9_a64 in out nocopy JTF_NUMBER_TABLE
    , p9_a65 in out nocopy JTF_NUMBER_TABLE
    , p9_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a67 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a68 in out nocopy JTF_NUMBER_TABLE
    , p9_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a70 in out nocopy JTF_NUMBER_TABLE
    , p9_a71 in out nocopy JTF_NUMBER_TABLE
    , p9_a72 in out nocopy JTF_NUMBER_TABLE
    , p9_a73 in out nocopy JTF_NUMBER_TABLE
    , p9_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a75 in out nocopy JTF_NUMBER_TABLE
    , p9_a76 in out nocopy JTF_NUMBER_TABLE
    , p9_a77 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a93 in out nocopy JTF_DATE_TABLE
    , p9_a94 in out nocopy JTF_NUMBER_TABLE
    , p9_a95 in out nocopy JTF_DATE_TABLE
    , p9_a96 in out nocopy JTF_NUMBER_TABLE
    , p9_a97 in out nocopy JTF_NUMBER_TABLE
    , p9_a98 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a99 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a100 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_VARCHAR2_TABLE_100
  );
  procedure update_job(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_wip_load_flag  VARCHAR2
    , p10_a0 in out nocopy  NUMBER
    , p10_a1 in out nocopy  NUMBER
    , p10_a2 in out nocopy  NUMBER
    , p10_a3 in out nocopy  NUMBER
    , p10_a4 in out nocopy  NUMBER
    , p10_a5 in out nocopy  VARCHAR2
    , p10_a6 in out nocopy  VARCHAR2
    , p10_a7 in out nocopy  NUMBER
    , p10_a8 in out nocopy  VARCHAR2
    , p10_a9 in out nocopy  VARCHAR2
    , p10_a10 in out nocopy  VARCHAR2
    , p10_a11 in out nocopy  NUMBER
    , p10_a12 in out nocopy  VARCHAR2
    , p10_a13 in out nocopy  VARCHAR2
    , p10_a14 in out nocopy  VARCHAR2
    , p10_a15 in out nocopy  DATE
    , p10_a16 in out nocopy  NUMBER
    , p10_a17 in out nocopy  NUMBER
    , p10_a18 in out nocopy  DATE
    , p10_a19 in out nocopy  NUMBER
    , p10_a20 in out nocopy  NUMBER
    , p10_a21 in out nocopy  DATE
    , p10_a22 in out nocopy  NUMBER
    , p10_a23 in out nocopy  NUMBER
    , p10_a24 in out nocopy  DATE
    , p10_a25 in out nocopy  NUMBER
    , p10_a26 in out nocopy  NUMBER
    , p10_a27 in out nocopy  NUMBER
    , p10_a28 in out nocopy  NUMBER
    , p10_a29 in out nocopy  VARCHAR2
    , p10_a30 in out nocopy  VARCHAR2
    , p10_a31 in out nocopy  VARCHAR2
    , p10_a32 in out nocopy  VARCHAR2
    , p10_a33 in out nocopy  VARCHAR2
    , p10_a34 in out nocopy  VARCHAR2
    , p10_a35 in out nocopy  VARCHAR2
    , p10_a36 in out nocopy  NUMBER
    , p10_a37 in out nocopy  VARCHAR2
    , p10_a38 in out nocopy  NUMBER
    , p10_a39 in out nocopy  VARCHAR2
    , p10_a40 in out nocopy  NUMBER
    , p10_a41 in out nocopy  VARCHAR2
    , p10_a42 in out nocopy  NUMBER
    , p10_a43 in out nocopy  NUMBER
    , p10_a44 in out nocopy  VARCHAR2
    , p10_a45 in out nocopy  NUMBER
    , p10_a46 in out nocopy  NUMBER
    , p10_a47 in out nocopy  NUMBER
    , p10_a48 in out nocopy  VARCHAR2
    , p10_a49 in out nocopy  NUMBER
    , p10_a50 in out nocopy  NUMBER
    , p10_a51 in out nocopy  VARCHAR2
    , p10_a52 in out nocopy  VARCHAR2
    , p10_a53 in out nocopy  NUMBER
    , p10_a54 in out nocopy  NUMBER
    , p10_a55 in out nocopy  VARCHAR2
    , p10_a56 in out nocopy  VARCHAR2
    , p10_a57 in out nocopy  VARCHAR2
    , p10_a58 in out nocopy  NUMBER
    , p10_a59 in out nocopy  NUMBER
    , p10_a60 in out nocopy  NUMBER
    , p10_a61 in out nocopy  NUMBER
    , p10_a62 in out nocopy  NUMBER
    , p10_a63 in out nocopy  NUMBER
    , p10_a64 in out nocopy  NUMBER
    , p10_a65 in out nocopy  NUMBER
    , p10_a66 in out nocopy  VARCHAR2
    , p10_a67 in out nocopy  VARCHAR2
    , p10_a68 in out nocopy  NUMBER
    , p10_a69 in out nocopy  VARCHAR2
    , p10_a70 in out nocopy  NUMBER
    , p10_a71 in out nocopy  NUMBER
    , p10_a72 in out nocopy  NUMBER
    , p10_a73 in out nocopy  NUMBER
    , p10_a74 in out nocopy  VARCHAR2
    , p10_a75 in out nocopy  NUMBER
    , p10_a76 in out nocopy  NUMBER
    , p10_a77 in out nocopy  VARCHAR2
    , p10_a78 in out nocopy  VARCHAR2
    , p10_a79 in out nocopy  VARCHAR2
    , p10_a80 in out nocopy  VARCHAR2
    , p10_a81 in out nocopy  VARCHAR2
    , p10_a82 in out nocopy  VARCHAR2
    , p10_a83 in out nocopy  VARCHAR2
    , p10_a84 in out nocopy  VARCHAR2
    , p10_a85 in out nocopy  VARCHAR2
    , p10_a86 in out nocopy  VARCHAR2
    , p10_a87 in out nocopy  VARCHAR2
    , p10_a88 in out nocopy  VARCHAR2
    , p10_a89 in out nocopy  VARCHAR2
    , p10_a90 in out nocopy  VARCHAR2
    , p10_a91 in out nocopy  VARCHAR2
    , p10_a92 in out nocopy  VARCHAR2
    , p10_a93 in out nocopy  DATE
    , p10_a94 in out nocopy  NUMBER
    , p10_a95 in out nocopy  DATE
    , p10_a96 in out nocopy  NUMBER
    , p10_a97 in out nocopy  NUMBER
    , p10_a98 in out nocopy  VARCHAR2
    , p10_a99 in out nocopy  VARCHAR2
    , p10_a100 in out nocopy  VARCHAR2
    , p11_a0 in out nocopy JTF_NUMBER_TABLE
    , p11_a1 in out nocopy JTF_NUMBER_TABLE
    , p11_a2 in out nocopy JTF_NUMBER_TABLE
    , p11_a3 in out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a4 in out nocopy JTF_NUMBER_TABLE
    , p11_a5 in out nocopy JTF_NUMBER_TABLE
    , p11_a6 in out nocopy JTF_NUMBER_TABLE
    , p11_a7 in out nocopy JTF_NUMBER_TABLE
    , p11_a8 in out nocopy JTF_DATE_TABLE
    , p11_a9 in out nocopy JTF_NUMBER_TABLE
    , p11_a10 in out nocopy JTF_DATE_TABLE
    , p11_a11 in out nocopy JTF_NUMBER_TABLE
    , p11_a12 in out nocopy JTF_NUMBER_TABLE
    , p11_a13 in out nocopy JTF_NUMBER_TABLE
    , p11_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 in out nocopy JTF_NUMBER_TABLE
    , p11_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 in out nocopy JTF_NUMBER_TABLE
    , p11_a23 in out nocopy JTF_NUMBER_TABLE
    , p11_a24 in out nocopy JTF_DATE_TABLE
    , p11_a25 in out nocopy JTF_NUMBER_TABLE
    , p11_a26 in out nocopy JTF_NUMBER_TABLE
    , p11_a27 in out nocopy JTF_DATE_TABLE
    , p11_a28 in out nocopy JTF_NUMBER_TABLE
    , p11_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a30 in out nocopy JTF_DATE_TABLE
    , p11_a31 in out nocopy JTF_NUMBER_TABLE
    , p11_a32 in out nocopy JTF_NUMBER_TABLE
    , p11_a33 in out nocopy JTF_DATE_TABLE
    , p11_a34 in out nocopy JTF_NUMBER_TABLE
    , p11_a35 in out nocopy JTF_NUMBER_TABLE
    , p11_a36 in out nocopy JTF_NUMBER_TABLE
    , p11_a37 in out nocopy JTF_NUMBER_TABLE
    , p11_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a39 in out nocopy JTF_NUMBER_TABLE
    , p11_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a56 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure insert_turnover_notes(p_api_version  NUMBER
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
    , p9_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 in out nocopy JTF_DATE_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
  );
end ahl_prd_workorder_pvt_w;

/
