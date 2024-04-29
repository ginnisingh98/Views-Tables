--------------------------------------------------------
--  DDL for Package CSI_JAVA_INTERFACE_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_JAVA_INTERFACE_PKG_W" AUTHID CURRENT_USER as
  /* $Header: csivjiws.pls 120.19.12010000.2 2009/05/25 05:18:02 dsingire ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy csi_java_interface_pkg.csi_output_tbl_ib, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t csi_java_interface_pkg.csi_output_tbl_ib, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy csi_java_interface_pkg.csi_coverage_tbl_ib, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t csi_java_interface_pkg.csi_coverage_tbl_ib, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy csi_java_interface_pkg.dpl_instance_tbl, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t csi_java_interface_pkg.dpl_instance_tbl, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
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
  procedure split_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
    , p_quantity1  NUMBER
    , p_quantity2  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p13_a0 in out nocopy  NUMBER
    , p13_a1 in out nocopy  DATE
    , p13_a2 in out nocopy  DATE
    , p13_a3 in out nocopy  NUMBER
    , p13_a4 in out nocopy  NUMBER
    , p13_a5 in out nocopy  NUMBER
    , p13_a6 in out nocopy  VARCHAR2
    , p13_a7 in out nocopy  NUMBER
    , p13_a8 in out nocopy  VARCHAR2
    , p13_a9 in out nocopy  NUMBER
    , p13_a10 in out nocopy  VARCHAR2
    , p13_a11 in out nocopy  NUMBER
    , p13_a12 in out nocopy  NUMBER
    , p13_a13 in out nocopy  NUMBER
    , p13_a14 in out nocopy  NUMBER
    , p13_a15 in out nocopy  VARCHAR2
    , p13_a16 in out nocopy  NUMBER
    , p13_a17 in out nocopy  VARCHAR2
    , p13_a18 in out nocopy  VARCHAR2
    , p13_a19 in out nocopy  NUMBER
    , p13_a20 in out nocopy  VARCHAR2
    , p13_a21 in out nocopy  VARCHAR2
    , p13_a22 in out nocopy  VARCHAR2
    , p13_a23 in out nocopy  VARCHAR2
    , p13_a24 in out nocopy  VARCHAR2
    , p13_a25 in out nocopy  VARCHAR2
    , p13_a26 in out nocopy  VARCHAR2
    , p13_a27 in out nocopy  VARCHAR2
    , p13_a28 in out nocopy  VARCHAR2
    , p13_a29 in out nocopy  VARCHAR2
    , p13_a30 in out nocopy  VARCHAR2
    , p13_a31 in out nocopy  VARCHAR2
    , p13_a32 in out nocopy  VARCHAR2
    , p13_a33 in out nocopy  VARCHAR2
    , p13_a34 in out nocopy  VARCHAR2
    , p13_a35 in out nocopy  VARCHAR2
    , p13_a36 in out nocopy  NUMBER
    , p13_a37 in out nocopy  VARCHAR2
    , p13_a38 in out nocopy  DATE
    , p13_a39 in out nocopy  NUMBER
    , p14_a0 out nocopy  NUMBER
    , p14_a1 out nocopy  VARCHAR2
    , p14_a2 out nocopy  VARCHAR2
    , p14_a3 out nocopy  NUMBER
    , p14_a4 out nocopy  NUMBER
    , p14_a5 out nocopy  VARCHAR2
    , p14_a6 out nocopy  NUMBER
    , p14_a7 out nocopy  VARCHAR2
    , p14_a8 out nocopy  VARCHAR2
    , p14_a9 out nocopy  VARCHAR2
    , p14_a10 out nocopy  NUMBER
    , p14_a11 out nocopy  VARCHAR2
    , p14_a12 out nocopy  VARCHAR2
    , p14_a13 out nocopy  NUMBER
    , p14_a14 out nocopy  NUMBER
    , p14_a15 out nocopy  VARCHAR2
    , p14_a16 out nocopy  VARCHAR2
    , p14_a17 out nocopy  VARCHAR2
    , p14_a18 out nocopy  NUMBER
    , p14_a19 out nocopy  VARCHAR2
    , p14_a20 out nocopy  DATE
    , p14_a21 out nocopy  DATE
    , p14_a22 out nocopy  VARCHAR2
    , p14_a23 out nocopy  NUMBER
    , p14_a24 out nocopy  NUMBER
    , p14_a25 out nocopy  VARCHAR2
    , p14_a26 out nocopy  NUMBER
    , p14_a27 out nocopy  NUMBER
    , p14_a28 out nocopy  NUMBER
    , p14_a29 out nocopy  NUMBER
    , p14_a30 out nocopy  NUMBER
    , p14_a31 out nocopy  NUMBER
    , p14_a32 out nocopy  NUMBER
    , p14_a33 out nocopy  NUMBER
    , p14_a34 out nocopy  NUMBER
    , p14_a35 out nocopy  VARCHAR2
    , p14_a36 out nocopy  NUMBER
    , p14_a37 out nocopy  NUMBER
    , p14_a38 out nocopy  NUMBER
    , p14_a39 out nocopy  NUMBER
    , p14_a40 out nocopy  DATE
    , p14_a41 out nocopy  VARCHAR2
    , p14_a42 out nocopy  DATE
    , p14_a43 out nocopy  DATE
    , p14_a44 out nocopy  VARCHAR2
    , p14_a45 out nocopy  VARCHAR2
    , p14_a46 out nocopy  VARCHAR2
    , p14_a47 out nocopy  VARCHAR2
    , p14_a48 out nocopy  VARCHAR2
    , p14_a49 out nocopy  VARCHAR2
    , p14_a50 out nocopy  VARCHAR2
    , p14_a51 out nocopy  VARCHAR2
    , p14_a52 out nocopy  VARCHAR2
    , p14_a53 out nocopy  VARCHAR2
    , p14_a54 out nocopy  VARCHAR2
    , p14_a55 out nocopy  VARCHAR2
    , p14_a56 out nocopy  VARCHAR2
    , p14_a57 out nocopy  VARCHAR2
    , p14_a58 out nocopy  VARCHAR2
    , p14_a59 out nocopy  VARCHAR2
    , p14_a60 out nocopy  VARCHAR2
    , p14_a61 out nocopy  VARCHAR2
    , p14_a62 out nocopy  VARCHAR2
    , p14_a63 out nocopy  VARCHAR2
    , p14_a64 out nocopy  NUMBER
    , p14_a65 out nocopy  NUMBER
    , p14_a66 out nocopy  VARCHAR2
    , p14_a67 out nocopy  NUMBER
    , p14_a68 out nocopy  VARCHAR2
    , p14_a69 out nocopy  VARCHAR2
    , p14_a70 out nocopy  VARCHAR2
    , p14_a71 out nocopy  VARCHAR2
    , p14_a72 out nocopy  NUMBER
    , p14_a73 out nocopy  VARCHAR2
    , p14_a74 out nocopy  NUMBER
    , p14_a75 out nocopy  NUMBER
    , p14_a76 out nocopy  NUMBER
    , p14_a77 out nocopy  VARCHAR2
    , p14_a78 out nocopy  VARCHAR2
    , p14_a79 out nocopy  VARCHAR2
    , p14_a80 out nocopy  NUMBER
    , p14_a81 out nocopy  NUMBER
    , p14_a82 out nocopy  NUMBER
    , p14_a83 out nocopy  DATE
    , p14_a84 out nocopy  VARCHAR2
    , p14_a85 out nocopy  VARCHAR2
    , p14_a86 out nocopy  VARCHAR2
    , p14_a87 out nocopy  NUMBER
    , p14_a88 out nocopy  VARCHAR2
    , p14_a89 out nocopy  NUMBER
    , p14_a90 out nocopy  NUMBER
    , p14_a91 out nocopy  VARCHAR2
    , p14_a92 out nocopy  NUMBER
    , p14_a93 out nocopy  VARCHAR2
    , p14_a94 out nocopy  NUMBER
    , p14_a95 out nocopy  DATE
    , p14_a96 out nocopy  VARCHAR2
    , p14_a97 out nocopy  VARCHAR2
    , p14_a98 out nocopy  VARCHAR2
    , p14_a99 out nocopy  VARCHAR2
    , p14_a100 out nocopy  VARCHAR2
    , p14_a101 out nocopy  VARCHAR2
    , p14_a102 out nocopy  VARCHAR2
    , p14_a103 out nocopy  VARCHAR2
    , p14_a104 out nocopy  VARCHAR2
    , p14_a105 out nocopy  VARCHAR2
    , p14_a106 out nocopy  VARCHAR2
    , p14_a107 out nocopy  VARCHAR2
    , p14_a108 out nocopy  VARCHAR2
    , p14_a109 out nocopy  VARCHAR2
    , p14_a110 out nocopy  VARCHAR2
    , p14_a111 out nocopy  NUMBER
    , p14_a112 out nocopy  VARCHAR2
    , p14_a113 out nocopy  NUMBER
    , p14_a114 out nocopy  VARCHAR2
    , p14_a115 out nocopy  NUMBER
    , p14_a116 out nocopy  VARCHAR2
    , p14_a117 out nocopy  VARCHAR2
    , p14_a118 out nocopy  NUMBER
    , p14_a119 out nocopy  VARCHAR2
    , p14_a120 out nocopy  NUMBER
    , p14_a121 out nocopy  NUMBER
    , p14_a122 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure split_item_instance_lines(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  DATE
    , p11_a2 in out nocopy  DATE
    , p11_a3 in out nocopy  NUMBER
    , p11_a4 in out nocopy  NUMBER
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  NUMBER
    , p11_a8 in out nocopy  VARCHAR2
    , p11_a9 in out nocopy  NUMBER
    , p11_a10 in out nocopy  VARCHAR2
    , p11_a11 in out nocopy  NUMBER
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  NUMBER
    , p11_a14 in out nocopy  NUMBER
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  NUMBER
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  NUMBER
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , p11_a29 in out nocopy  VARCHAR2
    , p11_a30 in out nocopy  VARCHAR2
    , p11_a31 in out nocopy  VARCHAR2
    , p11_a32 in out nocopy  VARCHAR2
    , p11_a33 in out nocopy  VARCHAR2
    , p11_a34 in out nocopy  VARCHAR2
    , p11_a35 in out nocopy  VARCHAR2
    , p11_a36 in out nocopy  NUMBER
    , p11_a37 in out nocopy  VARCHAR2
    , p11_a38 in out nocopy  DATE
    , p11_a39 in out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_NUMBER_TABLE
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_NUMBER_TABLE
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a20 out nocopy JTF_DATE_TABLE
    , p12_a21 out nocopy JTF_DATE_TABLE
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a23 out nocopy JTF_NUMBER_TABLE
    , p12_a24 out nocopy JTF_NUMBER_TABLE
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a26 out nocopy JTF_NUMBER_TABLE
    , p12_a27 out nocopy JTF_NUMBER_TABLE
    , p12_a28 out nocopy JTF_NUMBER_TABLE
    , p12_a29 out nocopy JTF_NUMBER_TABLE
    , p12_a30 out nocopy JTF_NUMBER_TABLE
    , p12_a31 out nocopy JTF_NUMBER_TABLE
    , p12_a32 out nocopy JTF_NUMBER_TABLE
    , p12_a33 out nocopy JTF_NUMBER_TABLE
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_NUMBER_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_NUMBER_TABLE
    , p12_a40 out nocopy JTF_DATE_TABLE
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a42 out nocopy JTF_DATE_TABLE
    , p12_a43 out nocopy JTF_DATE_TABLE
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a64 out nocopy JTF_NUMBER_TABLE
    , p12_a65 out nocopy JTF_NUMBER_TABLE
    , p12_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a67 out nocopy JTF_NUMBER_TABLE
    , p12_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a72 out nocopy JTF_NUMBER_TABLE
    , p12_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a74 out nocopy JTF_NUMBER_TABLE
    , p12_a75 out nocopy JTF_NUMBER_TABLE
    , p12_a76 out nocopy JTF_NUMBER_TABLE
    , p12_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a80 out nocopy JTF_NUMBER_TABLE
    , p12_a81 out nocopy JTF_NUMBER_TABLE
    , p12_a82 out nocopy JTF_NUMBER_TABLE
    , p12_a83 out nocopy JTF_DATE_TABLE
    , p12_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a87 out nocopy JTF_NUMBER_TABLE
    , p12_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a89 out nocopy JTF_NUMBER_TABLE
    , p12_a90 out nocopy JTF_NUMBER_TABLE
    , p12_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a92 out nocopy JTF_NUMBER_TABLE
    , p12_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a94 out nocopy JTF_NUMBER_TABLE
    , p12_a95 out nocopy JTF_DATE_TABLE
    , p12_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a111 out nocopy JTF_NUMBER_TABLE
    , p12_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a113 out nocopy JTF_NUMBER_TABLE
    , p12_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a115 out nocopy JTF_NUMBER_TABLE
    , p12_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a118 out nocopy JTF_NUMBER_TABLE
    , p12_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a120 out nocopy JTF_NUMBER_TABLE
    , p12_a121 out nocopy JTF_NUMBER_TABLE
    , p12_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure copy_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_contacts  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p_copy_inst_children  VARCHAR2
    , p13_a0 in out nocopy  NUMBER
    , p13_a1 in out nocopy  DATE
    , p13_a2 in out nocopy  DATE
    , p13_a3 in out nocopy  NUMBER
    , p13_a4 in out nocopy  NUMBER
    , p13_a5 in out nocopy  NUMBER
    , p13_a6 in out nocopy  VARCHAR2
    , p13_a7 in out nocopy  NUMBER
    , p13_a8 in out nocopy  VARCHAR2
    , p13_a9 in out nocopy  NUMBER
    , p13_a10 in out nocopy  VARCHAR2
    , p13_a11 in out nocopy  NUMBER
    , p13_a12 in out nocopy  NUMBER
    , p13_a13 in out nocopy  NUMBER
    , p13_a14 in out nocopy  NUMBER
    , p13_a15 in out nocopy  VARCHAR2
    , p13_a16 in out nocopy  NUMBER
    , p13_a17 in out nocopy  VARCHAR2
    , p13_a18 in out nocopy  VARCHAR2
    , p13_a19 in out nocopy  NUMBER
    , p13_a20 in out nocopy  VARCHAR2
    , p13_a21 in out nocopy  VARCHAR2
    , p13_a22 in out nocopy  VARCHAR2
    , p13_a23 in out nocopy  VARCHAR2
    , p13_a24 in out nocopy  VARCHAR2
    , p13_a25 in out nocopy  VARCHAR2
    , p13_a26 in out nocopy  VARCHAR2
    , p13_a27 in out nocopy  VARCHAR2
    , p13_a28 in out nocopy  VARCHAR2
    , p13_a29 in out nocopy  VARCHAR2
    , p13_a30 in out nocopy  VARCHAR2
    , p13_a31 in out nocopy  VARCHAR2
    , p13_a32 in out nocopy  VARCHAR2
    , p13_a33 in out nocopy  VARCHAR2
    , p13_a34 in out nocopy  VARCHAR2
    , p13_a35 in out nocopy  VARCHAR2
    , p13_a36 in out nocopy  NUMBER
    , p13_a37 in out nocopy  VARCHAR2
    , p13_a38 in out nocopy  DATE
    , p13_a39 in out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_NUMBER_TABLE
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_NUMBER_TABLE
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_NUMBER_TABLE
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_NUMBER_TABLE
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_DATE_TABLE
    , p14_a21 out nocopy JTF_DATE_TABLE
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_NUMBER_TABLE
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 out nocopy JTF_NUMBER_TABLE
    , p14_a27 out nocopy JTF_NUMBER_TABLE
    , p14_a28 out nocopy JTF_NUMBER_TABLE
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , p14_a30 out nocopy JTF_NUMBER_TABLE
    , p14_a31 out nocopy JTF_NUMBER_TABLE
    , p14_a32 out nocopy JTF_NUMBER_TABLE
    , p14_a33 out nocopy JTF_NUMBER_TABLE
    , p14_a34 out nocopy JTF_NUMBER_TABLE
    , p14_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a36 out nocopy JTF_NUMBER_TABLE
    , p14_a37 out nocopy JTF_NUMBER_TABLE
    , p14_a38 out nocopy JTF_NUMBER_TABLE
    , p14_a39 out nocopy JTF_NUMBER_TABLE
    , p14_a40 out nocopy JTF_DATE_TABLE
    , p14_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a42 out nocopy JTF_DATE_TABLE
    , p14_a43 out nocopy JTF_DATE_TABLE
    , p14_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a64 out nocopy JTF_NUMBER_TABLE
    , p14_a65 out nocopy JTF_NUMBER_TABLE
    , p14_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a67 out nocopy JTF_NUMBER_TABLE
    , p14_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a72 out nocopy JTF_NUMBER_TABLE
    , p14_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a74 out nocopy JTF_NUMBER_TABLE
    , p14_a75 out nocopy JTF_NUMBER_TABLE
    , p14_a76 out nocopy JTF_NUMBER_TABLE
    , p14_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a80 out nocopy JTF_NUMBER_TABLE
    , p14_a81 out nocopy JTF_NUMBER_TABLE
    , p14_a82 out nocopy JTF_NUMBER_TABLE
    , p14_a83 out nocopy JTF_DATE_TABLE
    , p14_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a87 out nocopy JTF_NUMBER_TABLE
    , p14_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a89 out nocopy JTF_NUMBER_TABLE
    , p14_a90 out nocopy JTF_NUMBER_TABLE
    , p14_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a92 out nocopy JTF_NUMBER_TABLE
    , p14_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a94 out nocopy JTF_NUMBER_TABLE
    , p14_a95 out nocopy JTF_DATE_TABLE
    , p14_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a111 out nocopy JTF_NUMBER_TABLE
    , p14_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a113 out nocopy JTF_NUMBER_TABLE
    , p14_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a115 out nocopy JTF_NUMBER_TABLE
    , p14_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a118 out nocopy JTF_NUMBER_TABLE
    , p14_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a120 out nocopy JTF_NUMBER_TABLE
    , p14_a121 out nocopy JTF_NUMBER_TABLE
    , p14_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  NUMBER := 0-1962.0724
    , p4_a40  DATE := fnd_api.g_miss_date
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  DATE := fnd_api.g_miss_date
    , p4_a43  DATE := fnd_api.g_miss_date
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  NUMBER := 0-1962.0724
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  NUMBER := 0-1962.0724
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  NUMBER := 0-1962.0724
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  NUMBER := 0-1962.0724
    , p4_a75  NUMBER := 0-1962.0724
    , p4_a76  NUMBER := 0-1962.0724
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  NUMBER := 0-1962.0724
    , p4_a82  NUMBER := 0-1962.0724
    , p4_a83  DATE := fnd_api.g_miss_date
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  NUMBER := 0-1962.0724
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  NUMBER := 0-1962.0724
    , p4_a90  NUMBER := 0-1962.0724
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  NUMBER := 0-1962.0724
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  NUMBER := 0-1962.0724
    , p4_a95  DATE := fnd_api.g_miss_date
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  NUMBER := 0-1962.0724
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  NUMBER := 0-1962.0724
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  NUMBER := 0-1962.0724
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  NUMBER := 0-1962.0724
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  NUMBER := 0-1962.0724
    , p4_a121  NUMBER := 0-1962.0724
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure getcontracts(product_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a10 out nocopy JTF_DATE_TABLE
    , p4_a11 out nocopy JTF_DATE_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a14 out nocopy JTF_DATE_TABLE
    , p4_a15 out nocopy JTF_DATE_TABLE
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a18 out nocopy JTF_DATE_TABLE
  );
  procedure get_coverage_for_prod_sch(contract_number  VARCHAR2
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , x_sequence_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_history_transactions(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p_instance_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_NUMBER_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_NUMBER_TABLE
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_NUMBER_TABLE
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_NUMBER_TABLE
    , p6_a98 out nocopy JTF_NUMBER_TABLE
    , p6_a99 out nocopy JTF_NUMBER_TABLE
    , p6_a100 out nocopy JTF_NUMBER_TABLE
    , p6_a101 out nocopy JTF_NUMBER_TABLE
    , p6_a102 out nocopy JTF_NUMBER_TABLE
    , p6_a103 out nocopy JTF_NUMBER_TABLE
    , p6_a104 out nocopy JTF_NUMBER_TABLE
    , p6_a105 out nocopy JTF_DATE_TABLE
    , p6_a106 out nocopy JTF_DATE_TABLE
    , p6_a107 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a108 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a109 out nocopy JTF_DATE_TABLE
    , p6_a110 out nocopy JTF_DATE_TABLE
    , p6_a111 out nocopy JTF_DATE_TABLE
    , p6_a112 out nocopy JTF_DATE_TABLE
    , p6_a113 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a115 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a118 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a129 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a130 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a131 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a132 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a133 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a134 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a135 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a136 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a137 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a138 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a139 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a140 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a141 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a142 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a143 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a144 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a145 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a146 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a147 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a148 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a149 out nocopy JTF_NUMBER_TABLE
    , p6_a150 out nocopy JTF_NUMBER_TABLE
    , p6_a151 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a152 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a153 out nocopy JTF_NUMBER_TABLE
    , p6_a154 out nocopy JTF_NUMBER_TABLE
    , p6_a155 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a156 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a157 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a158 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a159 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a160 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a161 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a162 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a163 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a164 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a167 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a170 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a171 out nocopy JTF_NUMBER_TABLE
    , p6_a172 out nocopy JTF_NUMBER_TABLE
    , p6_a173 out nocopy JTF_NUMBER_TABLE
    , p6_a174 out nocopy JTF_NUMBER_TABLE
    , p6_a175 out nocopy JTF_DATE_TABLE
    , p6_a176 out nocopy JTF_DATE_TABLE
    , p6_a177 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a183 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a184 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a185 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a186 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a187 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a188 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a189 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a190 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a191 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a192 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a193 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a194 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a195 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a196 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a197 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a198 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a199 out nocopy JTF_NUMBER_TABLE
    , p6_a200 out nocopy JTF_NUMBER_TABLE
    , p6_a201 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a202 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a203 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a204 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a205 out nocopy JTF_NUMBER_TABLE
    , p6_a206 out nocopy JTF_NUMBER_TABLE
    , p6_a207 out nocopy JTF_NUMBER_TABLE
    , p6_a208 out nocopy JTF_NUMBER_TABLE
    , p6_a209 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a210 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a211 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a212 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a213 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a214 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a215 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a216 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a217 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a218 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a219 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a220 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a221 out nocopy JTF_NUMBER_TABLE
    , p6_a222 out nocopy JTF_NUMBER_TABLE
    , p6_a223 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a224 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a225 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a226 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a227 out nocopy JTF_NUMBER_TABLE
    , p6_a228 out nocopy JTF_NUMBER_TABLE
    , p6_a229 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a230 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a231 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a232 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a233 out nocopy JTF_NUMBER_TABLE
    , p6_a234 out nocopy JTF_NUMBER_TABLE
    , p6_a235 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a236 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a237 out nocopy JTF_NUMBER_TABLE
    , p6_a238 out nocopy JTF_NUMBER_TABLE
    , p6_a239 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a240 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a241 out nocopy JTF_NUMBER_TABLE
    , p6_a242 out nocopy JTF_NUMBER_TABLE
    , p6_a243 out nocopy JTF_DATE_TABLE
    , p6_a244 out nocopy JTF_DATE_TABLE
    , p6_a245 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a246 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a247 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a248 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a249 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a250 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a251 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a252 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a253 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a254 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a255 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a256 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a257 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a258 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a259 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a260 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a261 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a262 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a263 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a264 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a265 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a266 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a267 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a268 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a269 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a270 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a271 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a272 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a273 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a274 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a275 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a276 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a277 out nocopy JTF_NUMBER_TABLE
    , p6_a278 out nocopy JTF_NUMBER_TABLE
    , p6_a279 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a280 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a281 out nocopy JTF_NUMBER_TABLE
    , p6_a282 out nocopy JTF_NUMBER_TABLE
    , p6_a283 out nocopy JTF_NUMBER_TABLE
    , p6_a284 out nocopy JTF_NUMBER_TABLE
    , p6_a285 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a286 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a287 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a288 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a289 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a290 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a291 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a292 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a293 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_DATE_TABLE
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a50 out nocopy JTF_NUMBER_TABLE
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a72 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a75 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a86 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
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
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a90 out nocopy JTF_NUMBER_TABLE
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_DATE_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
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
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_DATE_TABLE
    , p10_a14 out nocopy JTF_DATE_TABLE
    , p10_a15 out nocopy JTF_DATE_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_DATE_TABLE
    , p10_a40 out nocopy JTF_DATE_TABLE
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a48 out nocopy JTF_NUMBER_TABLE
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_NUMBER_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a4 out nocopy JTF_DATE_TABLE
    , p11_a5 out nocopy JTF_DATE_TABLE
    , p11_a6 out nocopy JTF_DATE_TABLE
    , p11_a7 out nocopy JTF_DATE_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a40 out nocopy JTF_NUMBER_TABLE
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a42 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a7 out nocopy JTF_DATE_TABLE
    , p12_a8 out nocopy JTF_DATE_TABLE
    , p12_a9 out nocopy JTF_DATE_TABLE
    , p12_a10 out nocopy JTF_DATE_TABLE
    , p12_a11 out nocopy JTF_DATE_TABLE
    , p12_a12 out nocopy JTF_DATE_TABLE
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a46 out nocopy JTF_NUMBER_TABLE
    , p12_a47 out nocopy JTF_NUMBER_TABLE
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_DATE_TABLE
    , p13_a8 out nocopy JTF_DATE_TABLE
    , p13_a9 out nocopy JTF_DATE_TABLE
    , p13_a10 out nocopy JTF_DATE_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p13_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a46 out nocopy JTF_NUMBER_TABLE
    , p13_a47 out nocopy JTF_DATE_TABLE
    , p13_a48 out nocopy JTF_NUMBER_TABLE
    , p13_a49 out nocopy JTF_NUMBER_TABLE
    , p13_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_instance_link_locations(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_instance_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_contact_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_contact_party_id  NUMBER
    , p_contact_flag  VARCHAR2
    , p_party_tbl  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure bld_instance_all_parents_tbl(p_subject_id  NUMBER
    , p_relationship_type_code  VARCHAR2
    , p_time_stamp  date
  );
  function get_instance_all_parents(p_subject_id  NUMBER
    , p_time_stamp  date
  ) return varchar2;
  procedure expire_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_subject_id  NUMBER
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
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
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  function get_instance_ids(p0_a0 in out nocopy JTF_NUMBER_TABLE
  ) return varchar2;
end csi_java_interface_pkg_w;

/
