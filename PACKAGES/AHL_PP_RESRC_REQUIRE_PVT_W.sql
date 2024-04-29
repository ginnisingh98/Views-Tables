--------------------------------------------------------
--  DDL for Package AHL_PP_RESRC_REQUIRE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PP_RESRC_REQUIRE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWREQS.pls 120.2.12010000.3 2008/12/28 02:03:44 sracha ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_pp_resrc_require_pvt.resrc_require_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
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
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_pp_resrc_require_pvt.resrc_require_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_resrc_require(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_operation_flag  VARCHAR2
    , p_interface_flag  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 in out nocopy JTF_DATE_TABLE
    , p7_a16 in out nocopy JTF_DATE_TABLE
    , p7_a17 in out nocopy JTF_NUMBER_TABLE
    , p7_a18 in out nocopy JTF_NUMBER_TABLE
    , p7_a19 in out nocopy JTF_NUMBER_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 in out nocopy JTF_NUMBER_TABLE
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 in out nocopy JTF_NUMBER_TABLE
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 in out nocopy JTF_NUMBER_TABLE
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a28 in out nocopy JTF_NUMBER_TABLE
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_DATE_TABLE
    , p7_a35 in out nocopy JTF_NUMBER_TABLE
    , p7_a36 in out nocopy JTF_NUMBER_TABLE
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_DATE_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_DATE_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a58 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ahl_pp_resrc_require_pvt_w;

/
