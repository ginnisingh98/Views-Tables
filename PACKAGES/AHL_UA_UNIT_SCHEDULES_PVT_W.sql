--------------------------------------------------------
--  DDL for Package AHL_UA_UNIT_SCHEDULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_UNIT_SCHEDULES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWUUSS.pls 120.3 2006/05/17 02:27 amsriniv noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ahl_ua_unit_schedules_pvt.unit_schedules_result_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ahl_ua_unit_schedules_pvt.unit_schedules_result_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ahl_ua_unit_schedules_pvt.unit_schedule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t ahl_ua_unit_schedules_pvt.unit_schedule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out nocopy ahl_ua_unit_schedules_pvt.visit_schedule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t ahl_ua_unit_schedules_pvt.visit_schedule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure search_unit_schedules(p_api_version  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_mevent_details(p_api_version  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_prec_succ_event_info(p_api_version  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_unit_config_id  NUMBER
    , p_start_date_time  date
    , p_end_date_time  date
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  DATE
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , x_is_prec_conflict out nocopy  VARCHAR2
    , x_is_prec_org_in_ou out nocopy  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  VARCHAR2
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  NUMBER
    , p11_a4 out nocopy  DATE
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  VARCHAR2
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  DATE
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  DATE
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  DATE
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  NUMBER
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  NUMBER
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  NUMBER
    , p11_a36 out nocopy  NUMBER
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  NUMBER
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
    , p11_a61 out nocopy  VARCHAR2
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  VARCHAR2
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  VARCHAR2
    , p11_a66 out nocopy  VARCHAR2
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  VARCHAR2
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  NUMBER
    , p11_a71 out nocopy  VARCHAR2
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  NUMBER
    , p11_a74 out nocopy  VARCHAR2
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  VARCHAR2
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  DATE
    , p12_a4 out nocopy  DATE
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  VARCHAR2
    , p12_a7 out nocopy  NUMBER
    , p12_a8 out nocopy  VARCHAR2
    , p12_a9 out nocopy  DATE
    , p12_a10 out nocopy  DATE
    , p12_a11 out nocopy  NUMBER
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  NUMBER
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  NUMBER
    , p12_a16 out nocopy  NUMBER
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  NUMBER
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  NUMBER
    , p12_a25 out nocopy  VARCHAR2
    , p12_a26 out nocopy  VARCHAR2
    , p12_a27 out nocopy  VARCHAR2
    , p12_a28 out nocopy  VARCHAR2
    , p12_a29 out nocopy  VARCHAR2
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  VARCHAR2
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  VARCHAR2
    , p12_a37 out nocopy  VARCHAR2
    , p12_a38 out nocopy  VARCHAR2
    , p12_a39 out nocopy  VARCHAR2
    , p12_a40 out nocopy  VARCHAR2
    , p12_a41 out nocopy  VARCHAR2
    , p12_a42 out nocopy  VARCHAR2
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  VARCHAR2
    , x_is_succ_conflict out nocopy  VARCHAR2
    , x_is_succ_org_in_ou out nocopy  VARCHAR2
  );
end ahl_ua_unit_schedules_pvt_w;

 

/
