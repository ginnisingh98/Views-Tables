--------------------------------------------------------
--  DDL for Package CN_REASONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REASONS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwresns.pls 115.3 2003/07/04 01:43:11 jjhuang ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy cn_reasons_pub.notes_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t cn_reasons_pub.notes_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    );

  procedure show_analyst_notes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p_first  NUMBER
    , p_last  NUMBER
    , p_payment_worksheet_id  NUMBER
    , p_table_name  VARCHAR2
    , p_lookup_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  VARCHAR2
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  NUMBER
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  VARCHAR2
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  NUMBER
    , p13_a10 out nocopy  VARCHAR2
    , p13_a11 out nocopy  VARCHAR2
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  VARCHAR2
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 out nocopy JTF_DATE_TABLE
    , p14_a27 out nocopy JTF_NUMBER_TABLE
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , x_notes_count out nocopy  NUMBER
  );
  procedure manage_analyst_notes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_VARCHAR2_TABLE_100
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_DATE_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure show_last_analyst_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p_payment_worksheet_id  NUMBER
    , p_table_name  VARCHAR2
    , p_lookup_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , x_notes_count out nocopy  NUMBER
  );
end cn_reasons_pub_w;

 

/
