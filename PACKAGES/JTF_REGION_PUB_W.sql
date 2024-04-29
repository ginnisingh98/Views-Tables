--------------------------------------------------------
--  DDL for Package JTF_REGION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_REGION_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfregws.pls 120.2 2005/10/25 05:25:23 psanyal ship $ */
  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_result_table, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p4(t jtf_region_pub.ak_result_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_item_rec_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t jtf_region_pub.ak_item_rec_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_bind_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p6(t jtf_region_pub.ak_bind_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_region_items_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t jtf_region_pub.ak_region_items_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.short_varchar2_table, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p8(t jtf_region_pub.short_varchar2_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p9(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.long_varchar2_table, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p9(t jtf_region_pub.long_varchar2_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000);

  procedure rosetta_table_copy_in_p10(t OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p10(t jtf_region_pub.number_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure get_regions(p_get_region_codes JTF_VARCHAR2_TABLE_100
    , p_get_application_id  NUMBER
    , p_get_responsibility_ids JTF_NUMBER_TABLE
    , p_skip_column_name  number
    , p_lang OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_ret_region_codes OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_resp_ids OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p_ret_object_name OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_region_name OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p_ret_region_description OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p10_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
  );
  procedure get_region(p_region_code  VARCHAR2
    , p_application_id  NUMBER
    , p_responsibility_id  NUMBER
    , p_object_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_region_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_region_description OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p6_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
  );
  procedure ak_query(p_application_id  NUMBER
    , p_region_code  VARCHAR2
    , p_where_clause  VARCHAR2
    , p_order_by_clause  VARCHAR2
    , p_responsibility_id  NUMBER
    , p_user_id  NUMBER
    , p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_max_rows IN OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p11_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a12 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a14 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a15 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a19 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a20 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a21 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a22 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a23 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a24 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a25 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a26 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a27 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a28 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a29 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a30 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a31 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a32 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a33 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a34 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a35 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a36 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a37 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a38 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a39 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a40 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a41 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a42 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a43 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a44 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a45 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a46 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a47 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a48 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a49 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a50 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a51 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a52 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a53 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a54 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a55 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a56 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a57 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a58 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a59 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a60 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a61 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a62 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a63 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a64 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a65 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a66 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a67 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a68 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a69 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a70 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a71 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a72 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a73 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a74 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a75 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a76 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a77 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a78 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a79 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a80 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a81 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a82 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a83 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a84 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a85 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a86 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a87 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a88 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a89 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a90 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a91 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a92 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a93 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a94 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a95 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a96 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a97 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a98 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p11_a99 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
end jtf_region_pub_w;

 

/
