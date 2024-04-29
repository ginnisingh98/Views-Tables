--------------------------------------------------------
--  DDL for Package CSI_MASS_EDIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_MASS_EDIT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csipmews.pls 120.5.12010000.3 2008/12/03 08:32:30 ngoutam ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy csi_mass_edit_pub.mass_edit_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t csi_mass_edit_pub.mass_edit_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy csi_mass_edit_pub.mass_edit_inst_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t csi_mass_edit_pub.mass_edit_inst_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy csi_mass_edit_pub.mass_edit_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t csi_mass_edit_pub.mass_edit_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p10(t out nocopy csi_mass_edit_pub.mass_edit_sys_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p10(t csi_mass_edit_pub.mass_edit_sys_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p12(t out nocopy csi_mass_edit_pub.mass_upd_rep_error_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t csi_mass_edit_pub.mass_upd_rep_error_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  NUMBER
    , p7_a21 in out nocopy  DATE
    , p7_a22 in out nocopy  DATE
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  DATE
    , p7_a28 in out nocopy  DATE
    , p7_a29 in out nocopy  DATE
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  NUMBER
    , p7_a32 in out nocopy  NUMBER
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  NUMBER
    , p7_a35 in out nocopy  NUMBER
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  NUMBER
    , p7_a41 in out nocopy  NUMBER
    , p7_a42 in out nocopy  NUMBER
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  DATE
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  NUMBER
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  NUMBER
    , p7_a68 in out nocopy  NUMBER
    , p7_a69 in out nocopy  NUMBER
    , p7_a70 in out nocopy  NUMBER
    , p7_a71 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_DATE_TABLE
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_DATE_TABLE
    , p9_a8 in out nocopy JTF_DATE_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_DATE_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  NUMBER
    , p7_a21 in out nocopy  DATE
    , p7_a22 in out nocopy  DATE
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  DATE
    , p7_a28 in out nocopy  DATE
    , p7_a29 in out nocopy  DATE
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  NUMBER
    , p7_a32 in out nocopy  NUMBER
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  NUMBER
    , p7_a35 in out nocopy  NUMBER
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  NUMBER
    , p7_a41 in out nocopy  NUMBER
    , p7_a42 in out nocopy  NUMBER
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  DATE
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  NUMBER
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  NUMBER
    , p7_a68 in out nocopy  NUMBER
    , p7_a69 in out nocopy  NUMBER
    , p7_a70 in out nocopy  NUMBER
    , p7_a71 in out nocopy  NUMBER
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_NUMBER_TABLE
    , p8_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 in out nocopy JTF_NUMBER_TABLE
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 in out nocopy JTF_NUMBER_TABLE
    , p8_a8 in out nocopy JTF_DATE_TABLE
    , p8_a9 in out nocopy JTF_DATE_TABLE
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_NUMBER_TABLE
    , p8_a28 in out nocopy JTF_NUMBER_TABLE
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_DATE_TABLE
    , p9_a8 in out nocopy JTF_DATE_TABLE
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_NUMBER_TABLE
    , p9_a27 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 in out nocopy JTF_DATE_TABLE
    , p10_a10 in out nocopy JTF_DATE_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_NUMBER_TABLE
    , p10_a29 in out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_mass_edit_batch(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  DATE := fnd_api.g_miss_date
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure delete_mass_edit_batches(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_2000
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_DATE_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_mass_edit_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  DATE
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_DATE_TABLE
    , p5_a22 out nocopy JTF_DATE_TABLE
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a27 out nocopy JTF_DATE_TABLE
    , p5_a28 out nocopy JTF_DATE_TABLE
    , p5_a29 out nocopy JTF_DATE_TABLE
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_NUMBER_TABLE
    , p5_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a33 out nocopy JTF_DATE_TABLE
    , p5_a34 out nocopy JTF_NUMBER_TABLE
    , p5_a35 out nocopy JTF_NUMBER_TABLE
    , p5_a36 out nocopy JTF_NUMBER_TABLE
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a40 out nocopy JTF_NUMBER_TABLE
    , p5_a41 out nocopy JTF_NUMBER_TABLE
    , p5_a42 out nocopy JTF_NUMBER_TABLE
    , p5_a43 out nocopy JTF_NUMBER_TABLE
    , p5_a44 out nocopy JTF_NUMBER_TABLE
    , p5_a45 out nocopy JTF_DATE_TABLE
    , p5_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a67 out nocopy JTF_NUMBER_TABLE
    , p5_a68 out nocopy JTF_NUMBER_TABLE
    , p5_a69 out nocopy JTF_NUMBER_TABLE
    , p5_a70 out nocopy JTF_NUMBER_TABLE
    , p5_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_DATE_TABLE
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure process_system_mass_update(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_entry_id  NUMBER
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_NUMBER_TABLE
    , p3_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 in out nocopy JTF_NUMBER_TABLE
    , p3_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 in out nocopy JTF_NUMBER_TABLE
    , p3_a14 in out nocopy JTF_NUMBER_TABLE
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a18 in out nocopy JTF_NUMBER_TABLE
    , p3_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a20 in out nocopy JTF_DATE_TABLE
    , p3_a21 in out nocopy JTF_DATE_TABLE
    , p3_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 in out nocopy JTF_NUMBER_TABLE
    , p3_a24 in out nocopy JTF_NUMBER_TABLE
    , p3_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a26 in out nocopy JTF_NUMBER_TABLE
    , p3_a27 in out nocopy JTF_NUMBER_TABLE
    , p3_a28 in out nocopy JTF_NUMBER_TABLE
    , p3_a29 in out nocopy JTF_NUMBER_TABLE
    , p3_a30 in out nocopy JTF_NUMBER_TABLE
    , p3_a31 in out nocopy JTF_NUMBER_TABLE
    , p3_a32 in out nocopy JTF_NUMBER_TABLE
    , p3_a33 in out nocopy JTF_NUMBER_TABLE
    , p3_a34 in out nocopy JTF_NUMBER_TABLE
    , p3_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a36 in out nocopy JTF_NUMBER_TABLE
    , p3_a37 in out nocopy JTF_NUMBER_TABLE
    , p3_a38 in out nocopy JTF_NUMBER_TABLE
    , p3_a39 in out nocopy JTF_NUMBER_TABLE
    , p3_a40 in out nocopy JTF_DATE_TABLE
    , p3_a41 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a42 in out nocopy JTF_DATE_TABLE
    , p3_a43 in out nocopy JTF_DATE_TABLE
    , p3_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a46 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a47 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a49 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a50 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a51 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a52 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a53 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a54 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a55 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a56 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a57 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a58 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a59 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a60 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a61 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a62 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a63 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a64 in out nocopy JTF_NUMBER_TABLE
    , p3_a65 in out nocopy JTF_NUMBER_TABLE
    , p3_a66 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a67 in out nocopy JTF_NUMBER_TABLE
    , p3_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a70 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a71 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a72 in out nocopy JTF_NUMBER_TABLE
    , p3_a73 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a74 in out nocopy JTF_NUMBER_TABLE
    , p3_a75 in out nocopy JTF_NUMBER_TABLE
    , p3_a76 in out nocopy JTF_NUMBER_TABLE
    , p3_a77 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a78 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a79 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a80 in out nocopy JTF_NUMBER_TABLE
    , p3_a81 in out nocopy JTF_NUMBER_TABLE
    , p3_a82 in out nocopy JTF_NUMBER_TABLE
    , p3_a83 in out nocopy JTF_DATE_TABLE
    , p3_a84 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a85 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a86 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a87 in out nocopy JTF_NUMBER_TABLE
    , p3_a88 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a89 in out nocopy JTF_NUMBER_TABLE
    , p3_a90 in out nocopy JTF_NUMBER_TABLE
    , p3_a91 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a92 in out nocopy JTF_NUMBER_TABLE
    , p3_a93 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a94 in out nocopy JTF_NUMBER_TABLE
    , p3_a95 in out nocopy JTF_DATE_TABLE
    , p3_a96 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a97 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a98 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a99 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a100 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a101 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a102 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a103 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a104 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a105 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a106 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a107 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a108 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a109 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a110 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a111 in out nocopy JTF_NUMBER_TABLE
    , p3_a112 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a113 in out nocopy JTF_NUMBER_TABLE
    , p3_a114 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a115 in out nocopy JTF_NUMBER_TABLE
    , p3_a116 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a117 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a118 in out nocopy JTF_NUMBER_TABLE
    , p3_a119 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a120 in out nocopy JTF_NUMBER_TABLE
    , p3_a121 in out nocopy JTF_NUMBER_TABLE
    , p3_a122 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_DATE_TABLE
    , p4_a6 in out nocopy JTF_DATE_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_NUMBER_TABLE
    , p4_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_NUMBER_TABLE
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_NUMBER_TABLE
    , p6_a33 in out nocopy JTF_DATE_TABLE
    , p6_a34 in out nocopy JTF_NUMBER_TABLE
    , p6_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  DATE
    , p7_a2 in out nocopy  DATE
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  NUMBER
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  NUMBER
    , p7_a12 in out nocopy  NUMBER
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  NUMBER
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  NUMBER
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  DATE
    , p7_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure identify_system_for_update(p_txn_line_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_system_batch(p_entry_id  NUMBER
    , p_txn_line_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  );
end csi_mass_edit_pub_w;

/
