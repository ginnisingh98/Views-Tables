--------------------------------------------------------
--  DDL for Package AHL_MC_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_RULE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWMCRS.pls 120.0.12010000.2 2008/11/26 14:11:12 sathapli ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ahl_mc_rule_pvt.ui_rule_stmt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
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
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p3(t ahl_mc_rule_pvt.ui_rule_stmt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_mc_rule_pvt.rule_stmt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
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
    , a36 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ahl_mc_rule_pvt.rule_stmt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_mc_rule_pvt.rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ahl_mc_rule_pvt.rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure load_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rule_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure insert_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_module  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_VARCHAR2_TABLE_100
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_100
    , p8_a18 JTF_VARCHAR2_TABLE_100
    , p8_a19 JTF_VARCHAR2_TABLE_100
    , p8_a20 JTF_VARCHAR2_TABLE_100
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p8_a22 JTF_NUMBER_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_NUMBER_TABLE
    , p8_a25 JTF_VARCHAR2_TABLE_100
    , p8_a26 JTF_VARCHAR2_TABLE_200
    , p8_a27 JTF_VARCHAR2_TABLE_200
    , p8_a28 JTF_VARCHAR2_TABLE_200
    , p8_a29 JTF_VARCHAR2_TABLE_200
    , p8_a30 JTF_VARCHAR2_TABLE_200
    , p8_a31 JTF_VARCHAR2_TABLE_200
    , p8_a32 JTF_VARCHAR2_TABLE_200
    , p8_a33 JTF_VARCHAR2_TABLE_200
    , p8_a34 JTF_VARCHAR2_TABLE_200
    , p8_a35 JTF_VARCHAR2_TABLE_200
    , p8_a36 JTF_VARCHAR2_TABLE_200
    , p8_a37 JTF_VARCHAR2_TABLE_200
    , p8_a38 JTF_VARCHAR2_TABLE_200
    , p8_a39 JTF_VARCHAR2_TABLE_200
    , p8_a40 JTF_VARCHAR2_TABLE_200
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  DATE
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  NUMBER
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  DATE
    , p9_a14 in out nocopy  DATE
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
  );
  procedure update_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_module  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  DATE
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  DATE
    , p8_a14  DATE
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_VARCHAR2_TABLE_100
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_100
    , p9_a22 JTF_NUMBER_TABLE
    , p9_a23 JTF_NUMBER_TABLE
    , p9_a24 JTF_NUMBER_TABLE
    , p9_a25 JTF_VARCHAR2_TABLE_100
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_VARCHAR2_TABLE_200
    , p9_a37 JTF_VARCHAR2_TABLE_200
    , p9_a38 JTF_VARCHAR2_TABLE_200
    , p9_a39 JTF_VARCHAR2_TABLE_200
    , p9_a40 JTF_VARCHAR2_TABLE_200
  );
  procedure delete_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  DATE
    , p7_a14  DATE
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
  );
  procedure get_rules_for_position(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mc_header_id  NUMBER
    , p_encoded_path  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_DATE_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_DATE_TABLE
    , p9_a14 out nocopy JTF_DATE_TABLE
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_mc_rule_pvt_w;

/
