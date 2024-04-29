--------------------------------------------------------
--  DDL for Package AHL_VWP_VISITS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISITS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWVSTS.pls 120.2.12010000.2 2009/12/10 11:38:02 tchimira ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ahl_vwp_visits_pvt.visit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_4000
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ahl_vwp_visits_pvt.visit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_4000
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_vwp_visits_pvt.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ahl_vwp_visits_pvt.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_visit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_DATE_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 in out nocopy JTF_DATE_TABLE
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_NUMBER_TABLE
    , p5_a20 in out nocopy JTF_DATE_TABLE
    , p5_a21 in out nocopy JTF_NUMBER_TABLE
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_DATE_TABLE
    , p5_a24 in out nocopy JTF_DATE_TABLE
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 in out nocopy JTF_NUMBER_TABLE
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_NUMBER_TABLE
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a43 in out nocopy JTF_NUMBER_TABLE
    , p5_a44 in out nocopy JTF_NUMBER_TABLE
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a46 in out nocopy JTF_NUMBER_TABLE
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a63 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a64 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a65 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a67 in out nocopy JTF_NUMBER_TABLE
    , p5_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 in out nocopy JTF_NUMBER_TABLE
    , p5_a71 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a72 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a73 in out nocopy JTF_NUMBER_TABLE
    , p5_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a75 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a76 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a77 in out nocopy JTF_NUMBER_TABLE
    , p5_a78 in out nocopy JTF_NUMBER_TABLE
    , p5_a79 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a80 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a81 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_visit_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  VARCHAR2
    , p6_a80 out nocopy  VARCHAR2
    , p6_a81 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_vwp_visits_pvt_w;

/
