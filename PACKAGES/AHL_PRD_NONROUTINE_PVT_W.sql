--------------------------------------------------------
--  DDL for Package AHL_PRD_NONROUTINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_NONROUTINE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPNRS.pls 120.3.12010000.3 2010/03/23 10:28:25 manesing ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_prd_nonroutine_pvt.sr_task_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_400
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_400
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_DATE_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
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
    , a63 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p2(t ahl_prd_nonroutine_pvt.sr_task_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_400
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_400
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_prd_nonroutine_pvt.mr_association_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t ahl_prd_nonroutine_pvt.mr_association_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_nonroutine_job(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_DATE_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 in out nocopy JTF_NUMBER_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_NUMBER_TABLE
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_NUMBER_TABLE
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 in out nocopy JTF_NUMBER_TABLE
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a18 in out nocopy JTF_NUMBER_TABLE
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a24 in out nocopy JTF_NUMBER_TABLE
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a26 in out nocopy JTF_NUMBER_TABLE
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_NUMBER_TABLE
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p8_a32 in out nocopy JTF_NUMBER_TABLE
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 in out nocopy JTF_NUMBER_TABLE
    , p8_a36 in out nocopy JTF_NUMBER_TABLE
    , p8_a37 in out nocopy JTF_NUMBER_TABLE
    , p8_a38 in out nocopy JTF_NUMBER_TABLE
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 in out nocopy JTF_NUMBER_TABLE
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 in out nocopy JTF_NUMBER_TABLE
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a45 in out nocopy JTF_NUMBER_TABLE
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a47 in out nocopy JTF_DATE_TABLE
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
  );
end ahl_prd_nonroutine_pvt_w;

/
